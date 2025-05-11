module fsm(clk,rst,pkt_valid,busy,parity_done,data_in,soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,detect_add,ld_state,laf_state,full_state,write_enb_reg,rst_int_reg,lfd_state);
 input clk,rst,pkt_valid,parity_done;
 input soft_reset_0,soft_reset_1,soft_reset_2;
 input fifo_full;
 input low_pkt_valid;
 input fifo_empty_0,fifo_empty_1,fifo_empty_2;
 input  [1:0]data_in;
 output busy;
 output detect_add,ld_state,lfd_state,laf_state;
 output full_state;
 output write_enb_reg,rst_int_reg;
 reg [1:0]addr;
 parameter DA=3'b000;
 parameter LFD=3'b001;
 parameter LD=3'b010;
 parameter LP=3'b011;
 parameter FFS=3'b100;
 parameter LAF=3'b101;
 parameter WTE=3'b110;
 parameter CPE=3'b111;
 
 reg [2:0]present,next;
 always @(posedge clk)
 begin
  if(!rst) addr<=2'bxx;
  else addr<=data_in[1:0];
 end
 
 //present state assignment
 always @(posedge clk)
 begin
  if(!rst) present<=DA;
  else if(soft_reset_0 || soft_reset_1 || soft_reset_2) present<=DA;
  else  present<=next;
 end
 
 //next state logic
 always @(*)
 begin
   next=DA;
   case(present)
   DA:begin
      if((pkt_valid & data_in[1:0]==0 & fifo_empty_0 )||(pkt_valid & data_in[1:0]==1 & fifo_empty_1 )||(pkt_valid & data_in[1:0]==2 & fifo_empty_2))
      begin
        next=LFD;
      end
      else if((pkt_valid & data_in[1:0]==0 & !fifo_empty_0)||(pkt_valid & data_in[1:0]==0 & !fifo_empty_0)||(pkt_valid & data_in[1:0]==0 & !fifo_empty_0))
      begin
        next=WTE;
      end
    else next=DA;
   end
  LFD:next=LD;
  LD:begin
     if(fifo_full) next=FFS;
     else if(!fifo_full & !pkt_valid) next=LP;
     else next=LD;
     end
  LP:next=CPE;
  CPE:begin
      if(!fifo_full) next=DA;
      else if(fifo_full) next=FFS;
      end
   FFS:begin
       if(fifo_full) next=FFS;
       else if(!fifo_full) next=LAF;
       end
   LAF:begin
       if(!parity_done && !low_pkt_valid) next=LD;
       else if(parity_done) next=DA;
       else if(!parity_done && low_pkt_valid) next=LP;
       end
   WTE:begin
       if((fifo_empty_0 && addr==0)||(fifo_empty_1 && addr==1)||(fifo_empty_2 &&addr==2))
       begin
         next=LFD;
       end
       else next=WTE;
       end
    endcase
   end
   
   //output logic
   assign detect_add = (present==DA)?1'b1:1'b0;
   assign lfd_state=(present ==LFD)?1'b1:1'b0;
   assign ld_state=(present==LD)?1'b1:1'b0;
   assign laf_state=(present==LAF)?1'b1:1'b0;
   assign busy=((present==LFD)||(present==LP)||(present==FFS)||(present==LAF)||(present==WTE)||(present==CPE))?1'b1:1'b0;
   assign write_enb_reg =((present==LD)||(present==LAF)||(present==LP))?1'b1:1'b0;
   assign full_state=(present==FFS)?1'b1:1'b0;
   assign rst_int_reg=(present==CPE)?1'b1:1'b0;
endmodule

