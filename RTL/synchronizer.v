module synchronizer(detect_add,data_in,write_enb_reg,clock,resetn,vld_out_0,vld_out_1,vld_out_2,read_enb_0,read_enb_1,read_enb_2,write_enb,fifo_full,empty_0,empty_1,empty_2,soft_reset_0,soft_reset_1,soft_reset_2,full_0,full_1,full_2);

input detect_add,write_enb_reg,clock,resetn,read_enb_0,read_enb_1,read_enb_2,empty_0,empty_1,empty_2,full_0,full_1,full_2;
input[1:0]data_in; 
output vld_out_0,vld_out_1,vld_out_2;
output reg[2:0]write_enb;
output reg fifo_full,soft_reset_0,soft_reset_1,soft_reset_2;

wire sf_0,sf_1,sf_2;

//CAPTURING ADDRESS LOGIC
  
	reg [1:0]fifo_addr;
  	always@(posedge clock)
  	begin
	  	if(!resetn)
		  fifo_addr <= 2'b00;
		  else if(detect_add)
		  fifo_addr <= data_in;
	end

//WRITE LOGIC 
	always@(*)
	begin
		if(write_enb_reg)
		begin
			case(fifo_addr)
				2'b00   : write_enb = 3'b001;
				2'b01   : write_enb = 3'b010;
				2'b10   : write_enb = 3'b100;
				default : write_enb = 3'b000;
			endcase
		end
		else
			write_enb = 3'b000;
	end	


//FIFO FULL LOGIC

	always@(*)
	begin
		case(fifo_addr)
			2'b00   : fifo_full = full_0;
		  	2'b01   : fifo_full = full_1;
		  	2'b10   : fifo_full = full_2;
		  	default : fifo_full = 1'b0;
	  	endcase
  	end

//SOFT RESET  LOGIC
	
	reg [4:0]count_0,count_1,count_2;

//SOFT RESET 1
	always@(posedge clock)
	begin
		if(!resetn)
		begin
			count_0      <= 5'b0;
			soft_reset_0 <= 1'b0;
		end
		else if(!vld_out_0)
		begin
			count_0      <= 5'b0;
			soft_reset_0 <= 1'b0;
		end
		else if(read_enb_0)
		begin
			count_0      <= 5'b0;
			soft_reset_0 <= 1'b0;
		end
		else if(sf_0)
		begin
			count_0      <= 5'b0;
			soft_reset_0 <= 1'b1;
		end
		else
		begin
			count_0      <= count_0 + 5'b1;
			soft_reset_0 <= 1'b0;
		end
	end

//SOFT RESET 2	
	always@(posedge clock)
	begin
		if(!resetn)
		begin
			count_1      <= 5'b0;
			soft_reset_1 <= 1'b0;
		end
		else if(!vld_out_1)
		begin
			count_1      <= 5'b0;
			soft_reset_1 <= 1'b0;
		end
		else if(read_enb_1)
		begin
			count_1      <= 5'b0;
			soft_reset_1 <= 1'b0;
		end
		else if(sf_1)
		begin
			count_1      <= 1'b0;
			soft_reset_1 <= 1'b1;
		end
		else
		begin
			count_1      <= count_1 + 1'b1;
			soft_reset_1 <= 1'b0;
		end
	end

//SOFT RESET 3
	always@(posedge clock)
	begin
		if(!resetn)
		begin
			count_2      <= 5'b0;
			soft_reset_2 <= 1'b0;
		end
		else if(!vld_out_2)
		begin
			count_2      <= 5'b0;
			soft_reset_2 <= 1'b0;
		end
		else if(read_enb_2)
		begin
			count_2      <= 5'b0;
			soft_reset_2 <= 1'b0;
		end
		else if(sf_2)
		begin
			count_2      <= 5'b0;
			soft_reset_2 <= 1'b1;
		end
		else
		begin
			count_2      <= count_2 + 5'b1;
			soft_reset_2 <= 1'b0;
		end
	end
// VALID OUT LOGIC
	assign vld_out_0 = !empty_0;
	assign vld_out_1 = !empty_1;
	assign vld_out_2 = !empty_2;

	assign sf_0 = (count_0 == 5'd29) ? 1'b1:1'b0;
	assign sf_1 = (count_1 == 5'd29) ? 1'b1:1'b0;
	assign sf_2 = (count_2 == 5'd29) ? 1'b1:1'b0;


	endmodule
		


  	


