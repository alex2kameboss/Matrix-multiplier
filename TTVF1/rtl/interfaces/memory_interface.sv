interface memory_interface (
    input   clk,
    input   reset_n
);
    
logic               req;
logic               ack;
logic               w_en;
logic   [15 : 0]    addr;
wire   [255 : 0]   data;

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

 clocking cb_drv_a @(posedge clk);
      input   req ;
      input   addr;
      input   w_en;
      output  data;
      output  ack ;
 endclocking : cb_drv_a

 clocking cb_drv_b @(posedge clk);
      input   req ;
      input   addr;
      input   w_en;
      output  data;
      output  ack ;
 endclocking : cb_drv_b

  clocking cb_drv_c @(posedge clk);
      input   req ;
      input   addr;
      input   w_en;
      input   data;
      output  ack ;
 endclocking : cb_drv_c

 clocking cb_monitor @ (posedge clk);
      input req ;
      input data ;
      input addr;
      input ack;
      input w_en;
 endclocking : cb_monitor

`ifdef ENABLE_ASSERTIONS
//Checkers for req-ack protocol

  property pr_generic_not_unknown (signal) 
  @(posedge clk) disable iff(~reset_n)
    !$isunknown(signal) ;
  endproperty   

  property ack_pulse; // Checks that ack is a pulse
    @(posedge clk) disable iff (~rst_n)
    $rose(ack) |-> ##1 $fell(ack);
  endproperty
  
  property req_without_ack; // Request had no response from server side
    @(posedge clk) disable iff (~rst_n)
    (req & ~ack) |=> ~req;
  endproperty
  
  property ack_without_req; // Ack without an active request 
    @(posedge clk) disable iff (~rst_n)
    (ack) |-> req;
  endproperty
  
  property ack_after_one_req_cc; //Acknowledge comes after one request HIGH clock cycle time
    @(posedge clk) disable iff (~rst_n)
    req & $changed(req) |-> ~ack;
  endproperty
  
  always @(posedge clk) 
    //REQ-ACK PROTOCOL CHECKERS
    assert property (ack_pulse) else
      $error("[%0t] PROTOCOL VIOLATION: ack_pulse assertion failed! Acknowledgement signal isn't a pulse", $time);
    assert property (req_without_ack) else
      $error("[%0t] PROTOCOL VIOLATION: Next request came without an acknowledgement from server!", $time);
    assert property (ack_without_req) else
      $error("[%0t] PROTOCOL VIOLATION: Acknowledgement came without a request from client!", $time);
    assert property (ack_after_one_req_cc) else
      $error("[%0t] PROTOCOL VIOLATION: Acknowledge came the same time as request was asserted!", $time);
    rst_never_X : assert property (pr_generic_not_unknown(reset_n)) else 
      $error("[%0t] Error! reset_n is unknown (=X/Z)", $time);

  `endif

endinterface
