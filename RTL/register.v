module register(clk,rst,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,,error,dout);
 input clk,rst,detect_add,lfd_state,ld_state,laf_state,full_state,fifo_full,rst_int_reg,pkt_valid;
 input [7:0]data_in;
 output reg low_pkt_valid,error,parity_done;
 output reg[7:0]dout;
 reg [7:0]header,ext_parity,int_parity,full_byte;
 //1.header byte storing
 always @(posedge clk)
 begin
 if(!rst) header<=0;
 else if(detect_add) header<=data_in;
 end
 //2.ext_parity
 always @(posedge clk)
 begin
 if(!rst) ext_parity<=0;
 else if(ld_state && !pkt_valid && !fifo_full) ext_parity<=data_in;
 end
 //clk,rst,pkt_valid,data_in,fifo_full,rst_int_reg,detect_add,ld_state,laf_state,full_state,lfd_state,parity_done,low_pkt_valid,error,din
 //3.int parity;
 always @(posedge clk)
 begin
 if(!rst) int_parity<=0;
 else if(rst_int_reg) int_parity<=0;
 else if(lfd_state) int_parity<=int_parity^header;
 else if(ld_state && pkt_valid && !fifo_full) int_parity<=int_parity^data_in;
 else if(ld_state && !pkt_valid && !fifo_full) int_parity<=int_parity^data_in;
 else if(laf_state) int_parity<=int_parity^full_byte;
 end
 
 //4.full byte
 always @(posedge clk)
 begin
 if(!rst) full_byte<=0;
 else if(ld_state && fifo_full) full_byte<=data_in;
 end
 
 //error logic
 always @(posedge clk)
 begin
 if(!rst) error<=0;
 else if(int_parity==ext_parity) error<=1;
 end
 
 //dout logic
 always @(posedge clk)
 begin
 if(!rst) dout<=0;
 else if(lfd_state) dout<=header;
 else if(ld_state && !fifo_full) dout<=data_in;
 else if(laf_state) dout<=full_byte;
 end
 
 //low pktvlaid
 always @(posedge clk)
 begin
 if(!rst) low_pkt_valid<=0;
 else if(ld_state && !pkt_valid && !low_pkt_valid) low_pkt_valid<=1;
 else low_pkt_valid<=0;
 end
 
 //parity done
 always @(posedge clk)
 begin
 if(!rst) parity_done<=0;
 else if(ld_state && !pkt_valid) parity_done<=1;
 else if(laf_state && low_pkt_valid && !parity_done) parity_done<=1;
 end
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 