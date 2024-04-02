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
`ifdef ENABLE_ASSERTIONS

  property pr_generic_not_unknown (signal) 
    @(posedge pclk) disable iff(~preset_n)
      !$isunknown(signal) ;
  endproperty ;   

  psel_never_X    : assert property (pr_generic_not_unknown(psel   )) else $display("[%0t] Error! psel is unknown (=X/Z)", $time);
  pwrite_never_X  : assert property (pr_generic_not_unknown(pwrite )) else $display("[%0t] Error! pwrite is unknown (=X/Z)", $time);
  penable_never_X : assert property (pr_generic_not_unknown(penable)) else $display("[%0t] Error! penable is unknown (=X/Z)", $time);
  pready_never_X  : assert property (pr_generic_not_unknown(pready )) else $display("[%0t] Error! pready is unknown (=X/Z)", $time);
  paddr_never_X   : assert property (pr_generic_not_unknown(paddr  )) else $display("[%0t] Error! paddr is unknown (=X/Z)", $time);
  pwdata_never_X  : assert property (pr_generic_not_unknown(pwdata )) else $display("[%0t] Error! pwdata is unknown (=X/Z)", $time);
  prdata_never_X  : assert property (pr_generic_not_unknown(prdata )) else $display("[%0t] Error! prdata is unknown (=X/Z)", $time);
  // pstrb_never_X   : assert property (pr_generic_not_unknown(pstrb  )) else $display("[%0t] Error! pstrb is unknown (=X/Z)", $time);
  // pprot_never_X   : assert property (pr_generic_not_unknown(pprot  )) else $display("[%0t] Error! pprot is unknown (=X/Z)", $time);
  
//paddr changed? -> transfer finished OR didn't start yet ((!psel))
  property idle_state ;
     @(posedge pclk) disable iff(!preset_n)
        (!psel) |=> (!psel) or (psel && !penable) ;
  endproperty

  property setup_state ;
     @(posedge pclk) disable iff(!preset_n)
        (psel && !penable) |=> (psel && penable && !pready) or (psel && penable && pready) ;
  endproperty

  property access_wait_state ;
    @(posedge pclk) disable iff(!preset_n)
       (psel && penable && !pready) |=> (psel && penable && !pready) or (psel && penable && pready) ;
  endproperty

  property access_last_state ;
    @(posedge pclk) disable iff(!preset_n)
       (psel && penable && pready) |=> (!psel) or (psel && !penable) ;
  endproperty

  property pr_generic_stable(signal) 
    @(posedge pclk) disable iff(!preset_n)
       !$stable(signal) |-> (psel && !penable) or (!psel) ;
  endproperty
//Some signals need to be treated separately. pwdata needs be stable only during write transfers (pwrite=1):
  property pwdata_in_wr_transfer ;  
    @(posedge pclk) disable iff(!preset_n)
       !$stable(pwdata) |-> (!pwrite) or ((psel && !penable) or (!psel)) ;
  endproperty
//The psel signal must be stable (=1) throughout the transfer, while penable signal must be stable (=1) during the whole access_phase.
  property penable_in_transfer ;
    @(posedge pclk) disable iff(!preset_n)
    $fell(penable) |-> (!psel) or ($past(penable) && $past(pready)) ;
  endproperty

  property psel_stable_in_transfer ;
    @(posedge pclk) disable iff(!preset_n)
       !psel && $past(psel) |-> $past(penable) && $past(pready) ; 
  endproperty    
//Another signal that must be treated separately is PSTRB which must be low during read transfers
  // property pstrb_low_at_read ;
  //   @(posedge pclk) disable iff(!preset_n)
  //      psel && !pwrite |-> pstrb == {(16/8){1'b0}} ;
  // endproperty  
`endif

endinterface