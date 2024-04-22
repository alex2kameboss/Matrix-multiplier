module top_tb();

  import uvm_pkg::*;
  import mem_pkg::*;
  import apb_pkg::*;
  import env_pkg::*;

  `include "uvm_macros.svh";

  bit clk;
  bit rst_n;

memory_interface a_bus(clk, rst_n), b_bus(clk, rst_n), c_bus(clk, rst_n);

apb_interface apb_if    ( .pclk(clk),
                         .preset_n(rst_n));
  top #(
    .ARRAY_WIDTH (32),
    .ARRAY_HEIGHT (4)
  ) i_dut (
    // control interface
    .config_bus (apb_if),
    .a_bus      (a_bus),
    .b_bus      (b_bus),
    .c_bus      (c_bus),
    .clk        (clk) ,
    .reset_n    (rst_n) 
);

initial begin
    uvm_config_db#(virtual memory_interface)::set(uvm_root::get(),"*.agnt_mem.*","memory_interface_instance_a",a_bus);
    uvm_config_db#(virtual memory_interface)::set(uvm_root::get(),"*.agnt_mem.*","memory_interface_instance_b",b_bus);
    uvm_config_db#(virtual memory_interface)::set(uvm_root::get(),"*.agnt_mem.*","memory_interface_instance_c",c_bus);
            
    uvm_config_db#(virtual apb_interface   )::set(uvm_root::get(),"*.agnt_apb.*","apb_interface_instance",apb_if);
    // // run_test("req_ack_test");
    // //run_test("req_ack_test1");
    // run_test("req_ack_test2");
end

initial begin
    forever begin
    #5 clk = ~clk;  
    end
end

initial 
begin
    rst_n = 1;
    #2;
    rst_n = 0;
    #2;
    rst_n = 1;
end 

endmodule