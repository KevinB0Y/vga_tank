`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:13:48 09/13/2013 
// Design Name: 
// Module Name:    vga_tank 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module vga_tank
   (
    input mclk,
    input rst,
    input btn,
    input start,
    output [7:0] rgb_8bits,
    output hsync,
    output vsync
    );

wire [10:0] count_h;
wire [ 9:0] count_v;

reg  [ 7:0] rgb_8bits;

reg  [10:0]  reg_h      = 11'd600;
reg  [ 9:0]  reg_v      = 10'd250;

reg  [10:0]  reg_col     ;
reg  [ 9:0]  reg_height  ;
reg  [ 9:0]  reg_random  ;

reg  [ 9:0]  timer1      ;
reg  [10:0]  reg_col1    ;
reg  [ 9:0]  reg_height1 ;
reg  [ 9:0]  reg_random1 ;

//parameter col_height=10'd200;
//parameter pixel_h = 11'd600;   //800*600*72 HZ 最低的列像素起始点：215，最多不超过1015.
//parameter pixel_v = 10'd250;   //800*600*72 HZ 最低的行像素起始点：26， 最多不超过626.

parameter     col_width = 11'd100;
parameter         img_h = 11'd50; 
parameter         img_v = 10'd50;
parameter       windows = 10'd250;

reg [15:0] cnt_flag;
reg flag;
//reg flag_fly;
//reg flag_gravity;
reg flag_btn;
reg flag_fresh;
reg flag_col1;
reg flag_fresh1;
reg flag_die;

integer cnt_score;

clk_div clk_div(
   .mclk(mclk),
	.rst(rst),
	.clk(clk)
	);
	
vga_setup vga_setup
   (
    .clk(clk),
	 .rst(rst),
	 .count_h(count_h),
	 .count_v(count_v)
    );	
	
//synthesis attribute box_type <img> "black_box" 
   
wire [7:0]  rom_dout; 
wire [11:0] addr;

wire [7:0]  dout0; 
wire [10:0] addr0;

wire [7:0]  dout1; 
wire [10:0] addr1;

img img(
	.clka(clk),
	.addra(addr),
	.douta(rom_dout)
	);

num0 num0 (
  .clka(clk), // input clka
  .addra(addr0), // input [10 : 0] addra
  .douta(dout0) // output [7 : 0] douta
);

num1 num1 (
  .clka(clk), // input clka
  .addra(addr1), // input [10 : 0] addra
  .douta(dout1) // output [7 : 0] douta
);

/*****************行列同步准备时间的assign********************/
assign hsync = (count_h<=11'd127)? 1'b0 : 1'b1;    //行同步段的准备时间
assign vsync = (count_v<=10'd3)?   1'b0 : 1'b1;    //列同步段的准备时间
/************************地址的赋值***********************/
assign addr =  ( count_v - ( reg_v  + 10'd1 )) * img_h  + ( count_h - ( reg_h   + 11'd1 ));
assign addr0 = ( count_v - ( 10'd50 + 10'd1 )) * 11'd25 + ( count_h - ( 11'd300 + 11'd1 ));
assign addr1 = ( count_v - ( 10'd50 + 10'd1 )) * 11'd25 + ( count_h - ( 11'd300 + 11'd1 ));
/*************************计分与死亡的判定*******************************/
  always @(posedge flag or posedge rst) 
    begin
      if (rst) 
        begin
              flag_die  <= 0;
              cnt_score <= 0;
        end
		  
      else if ((reg_col<=11'd750)&&(reg_col>=11'd600)) 
        begin
           if (
              (reg_v<=reg_height)                   
				     ||
              ((reg_v+img_v)>=(reg_height +windows))
              )  
             begin flag_die <= 1;           end
            else   
             begin flag_die <= flag_die;    end       
        end  
		
		else if ((reg_col1<=11'd750)&&(reg_col1>=11'd600))  
		   begin	
			    if (
                (reg_v<=reg_height1)                 
				       ||
                ((reg_v+img_v)>=(reg_height1+windows))
                )  
                begin flag_die <= 1;         end
            else   
                begin flag_die <= flag_die;  end
			end

    else if ((reg_col  == 11'd599)&&(flag_die == 0))
      begin cnt_score <= cnt_score + 1; end  
		  
    else if ((reg_col1 == 11'd599)&&(flag_die == 0))
      begin cnt_score <= cnt_score + 1; end  
        
    else if (!start)
		  begin flag_die <= 0;  cnt_score <= 0;  end
		else 
      begin flag_die <= flag_die;  end 
    end
/*****************************重力的时钟*******************************/
    always @(posedge clk or posedge rst)
      begin
      if(rst)
         begin
            cnt_flag <= 0;
                flag <= 0;
         end
      else if(cnt_flag == 50_000)
          begin 
            cnt_flag <= 0; 
                flag <= ~flag; 
          end 
      else 
        begin
            cnt_flag <= cnt_flag + 16'd1;
          end
      end
/*************************按脚有效的flag**********************/
    always@(posedge clk or posedge rst)
        if(rst)
         flag_btn <= 0;
        else if(btn)
        flag_btn <= 1;
        else
        flag_btn <= 0;
/*************************小鸟下落的控制**********************/
    always@(posedge flag or posedge rst)
     begin 

       if(rst)
         begin
          reg_h <= 11'd600;
          reg_v <= 10'd250;
         end

       else if (!start)
         begin
          reg_h <= 11'd600;
          reg_v <= 10'd250;
         end

       else 
         begin
          if(flag_die == 1)
                 begin
                   if(reg_v == 10'd576)
                     reg_v <= reg_v; 
                   else         
                     reg_v <= reg_v + 10'd1;
                  end
          else 
             begin 
               if(flag_btn == 0)
                 begin 
                  if(reg_v == 10'd576)
                     reg_v <= reg_v; 
                  else         
                     reg_v <= reg_v + 10'd1;
                end

              else if(flag_btn == 1)
                begin
                  if(reg_v == 10'd26)
                     reg_v <= reg_v;
                  else
                     reg_v <= reg_v - 10'd1;      
                end

           else begin
              reg_v <= reg_v;
              reg_h <= reg_h;
             end  
           end   
         end  

     end 
/*****************水管回到最右边的刷新reg*********************/
always @(posedge flag or posedge rst) 

begin
  if (rst) begin
    reg_col <= 11'd1200;
    flag_fresh <= 0;
  end

  else if(~start)
    begin
     reg_col <= 11'd1200;
     flag_fresh <= 0;
    end

  else   
    begin
      if(!flag_die)
        begin
          if(reg_col == 11'd300) 
            begin
              reg_col <= 11'd1200;
              flag_fresh <= 1;
            end  
  
          else  
            begin
              reg_col <= reg_col - 11'd1;
              flag_fresh <= 0;
            end
        end
      else  
           begin
               reg_col <= reg_col;
              flag_fresh <= 0;
           end      
	  end	  
end
/******************水管的窗口刷新reg********************/
always @(posedge clk or posedge rst) begin
  if (rst) begin
    reg_random <= 10'd100;
  end
  else if (reg_random == 10'd326) begin
    reg_random <= 10'd100;
  end
  else begin
    reg_random <= reg_random + 10'd1;
  end
end
/*****************水管回到最右边的窗口初始化赋值*****************/
always @(posedge clk or posedge rst) begin
  if (rst) begin
        reg_height <= 10'd100;    
  end
  else if (flag_fresh == 1) begin
        reg_height <= reg_random;   
  end
end
/***************水管1启动的倒计时***************/
  always @(posedge flag or posedge rst) 
    begin
    	if (rst) begin
    		timer1 <= 10'd400;
    		flag_col1 <= 0;
    	end
    
      else if(!start)
        begin
          timer1 <= 10'd400;
          flag_col1 <= 0;
        end

      else if(start) 
        begin
    	     if (timer1 == 0) 
             begin
    		       timer1 <= timer1;
    		       flag_col1 <= 1;
          	 end
           else 
            begin
        	     timer1 <= timer1 - 10'd1;
        	     flag_col1 <= 0;
            end
        end  

      else begin
              timer1 <= 10'd400;
              flag_col1 <= 0;
          end    
    end
/*****************水管1右移的reg******************/
always @(posedge flag or posedge rst) 

begin
  if (rst) begin
    reg_col1 <= 11'd1200;
    flag_fresh1 <= 0;
  end

  else if(!start)
    begin
     reg_col1 <= 11'd1200;                         
     flag_fresh1 <= 0;
    end

  else 
    begin  
      if(!flag_die)
        begin
          if(reg_col1 == 11'd300) 
            begin
              reg_col1 <= 11'd1200;
              flag_fresh1 <= 1;
            end  
          else if (flag_col1 == 1)
            begin
              reg_col1 <= reg_col1 - 11'd1;
              flag_fresh1 <= 0;
            end
        end
      else 
            begin
              reg_col1 <= reg_col1;
              flag_fresh1 <= 0;
            end       
    end
end
/****************水管1的窗口随机reg******************/
always @(posedge flag or posedge rst) begin
	if (rst) begin
		reg_random1 <= 10'd100;
	end
	else if (reg_random1 == 10'd326) begin
		reg_random1 <= 10'd100;
	end
	else begin
		reg_random1 <= reg_random1 + 10'd1;
	end
end
/***************水管1的顶部高度*****************/
always @(posedge clk or posedge rst) begin
	if (rst) begin
        reg_height1 <= 10'd250;		
	end
	else if (flag_fresh1 == 1) begin
        reg_height1 <= reg_random1;		
	end
end
/*****************vga显示的控制*******************/
always @(posedge clk or posedge rst) 
begin
	if (rst) 
		begin
	    rgb_8bits <= 8'b000_000_00;	
	    end
	else if (
		     ( count_h > reg_h ) && 
		     ( count_h < ( reg_h + img_h + 11'd1 )) && 
		     ( count_v > reg_v ) && 
		     ( count_v < ( reg_v + img_v + 10'd1 ))
		     )
        rgb_8bits <= rom_dout;		
    else if (
             ( (cnt_score%10) == 0 ) &&
             ( count_h > 11'd300 ) && 
             ( count_h < ( 11'd300 + 11'd25 + 11'd1 )) && 
             ( count_v > 10'd50 ) && 
             ( count_v < ( 10'd50  + 11'd50 + 10'd1 ))
            ) 
        rgb_8bits <= dout0;      
    else if (
             ( (cnt_score%10) == 1 ) &&
             ( count_h > 11'd300 ) && 
             ( count_h < ( 11'd300 + 11'd25 + 11'd1 )) && 
             ( count_v > 10'd50 ) && 
             ( count_v < ( 10'd50  + 11'd50 + 10'd1 ))
            ) 
        rgb_8bits <= dout1;           
    else if (
    	       (
    	       (count_h > (reg_col - col_width)) && 
    	       (count_h < reg_col)  && 
    	       (count_v > 10'd26)   &&
    	       (count_v < reg_height)
    	       )  
		        ||
    	       (
    	       (count_h > (reg_col - col_width)) &&
    	       (count_h < reg_col) &&
    	       (count_v > (reg_height+windows)) &&  
    	       (count_v < 10'd626)
				    )
    	    )
    		  rgb_8bits <= 8'b000_111_00;
    else if (
    	       (
    	       (count_h > (reg_col1 - col_width)) && 
    	       (count_h < reg_col1)  && 
    	       (count_v > 10'd26)   &&
    	       (count_v < reg_height1)
    	       )  
		        ||
    	       (
    	       (count_h > (reg_col1 - col_width)) &&
    	       (count_h < reg_col1) &&
    	       (count_v > (reg_height1+windows)) &&  
    	       (count_v < 10'd626)
				    )
    	    )
    	  	  rgb_8bits <= 8'b000_111_00;
    else
    	    begin
    	  	  rgb_8bits <= 8'b000_000_00;
    	    end 
end

endmodule  

