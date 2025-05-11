module top_block(clk,rst,read_enb_0,read_enb_1,read_enb_2,data_in,pkt_valid,dout_out_0,dout_out_1,dout_out_2,valid_out_0,valid_out_1,valid_out_2,error,busy);
  input clk,rst;
  input read_enb_0,read_enb_1,read_enb_2;
  input [7:0]data_in;
  input pkt_valid;
  output [7:0]dout_out_0,dout_out_1,dout_out_2;
  output valid_out_0,valid_out_1,valid_out_2;
  output error,busy;
  wire [7:0]din;
  wire [2:0]wr_en;
  
  //register instantiation
  register reg1(clk,rst,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,error,din);
  
  //fsm instanition 
  fsm routerfsm(clk,rst,pkt_valid,busy,parity_done,data_in[1:0],soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,empty_0,empty_1,empty_2,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);
  
  //synchronizer
  synchronizer router_synch(detect_add,data_in[1:0],write_enb_reg,clk,rst,valid_out_0,valid_out_1,valid_out_2,read_enb_0,read_enb_1,read_enb_2,wr_en,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2);
  
  //router fifos
  fifo_router f0(clk,rst,wr_en[0],soft_reset_0,read_enb_0,din,lfd_state,empty_0,dout_out_0,full_0);
  fifo_router f1(clk,rst,wr_en[1],soft_reset_1,read_enb_1,din,lfd_state,empty_1,dout_out_1,full_1);
  fifo_router f2(clk,rst,wr_en[2],soft_reset_2,read_enb_2,din,lfd_state,empty_2,dout_out_2,full_2);
endmodule

