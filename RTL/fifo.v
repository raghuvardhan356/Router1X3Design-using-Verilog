module fifo_router(clk,rst,wr_en,soft_rst,rd_en,data_in,lfd_state,empty,data_out,full);
  input clk,rst,soft_rst,wr_en,rd_en,lfd_state;
  input [7:0]data_in;
  output reg [7:0]data_out;
  output empty,full;
  reg lfd_state_delay;
  reg [4:0]wr_ptr,rd_ptr;
  reg [6:0]counter;
  reg [8:0]mem[0:15];

      always @(posedge clk)
           begin
             if(!rst)
                lfd_state_delay<=0;
             else 
             begin
                lfd_state_delay<=lfd_state;
                //lfd_state_delay<=lfd_state_temp;
             end
          end
    //write logic
    always @(posedge clk)
    begin
      if(!rst)
         wr_ptr<=0;
      else if(soft_rst)
         wr_ptr<=0;
      else if(wr_en && !full)
      begin 
          mem[wr_ptr[3:0]]<={lfd_state_delay,data_in};
          wr_ptr<=wr_ptr+1;
      end
    end
    //data_out logic
     always @(posedge clk)
     begin
       if(!rst)
         data_out<=8'bz;
       else if(soft_rst)
           data_out<=8'bz;
       else if(rd_en && !empty)
       begin
           if(counter!=0)
           begin
              data_out<=mem[rd_ptr[3:0]];
           end
           else
             data_out<=8'bz;
       end
       else
            data_out<=8'bz;
       
       end
       
       //read logic
       always @(posedge clk)
       begin
         if(!rst)
           rd_ptr<=0;
         else if(soft_rst)
            rd_ptr<=0;
         else if(rd_en && !empty)
         begin
           if(counter!=0)
           begin
             rd_ptr<=rd_ptr+1'b1;
           end
           else
             rd_ptr<=rd_ptr;
         end
         end
         
         //counter logic
         always @(posedge clk)
         begin
           if(!rst)
              counter<=0;
           else if(soft_rst)
              counter<=0;
           else if(rd_en && !empty)
           begin
               if(mem[rd_ptr[3:0]][8]==1'b1)
                 counter<=mem[rd_ptr[3:0]][7:2]+1'b1;
               else if(counter!=0)
               begin
                 counter<=counter-1'b1;
               end
               else counter <=0;
           end
           end
           //lfd_state_delay
           
          assign full=(wr_ptr==({~rd_ptr[4],rd_ptr[3:0]}))?1'b1:1'b0;
          assign empty =(wr_ptr==rd_ptr)?1'b1:1'b0;
                 
endmodule
