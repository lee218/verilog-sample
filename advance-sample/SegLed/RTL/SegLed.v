/****************************************Copyright (c)**************************************************
**                                      Dongdong   Studio 
**                                     
**---------------------------------------File Info-----------------------------------------------------
** File name:           SegLed
** Last modified Date:  2009-10-18
** Last Version:        1.0
** Descriptions:        SegLed
**------------------------------------------------------------------------------------------------------
** Created by:          dongdong
** Created date:        2009-10-18
** Version:             1.0
** Descriptions:        The original version
**
**------------------------------------------------------------------------------------------------------
** Modified by:			
** Modified date:		
** Version:				
** Descriptions:		
**
**------------------------------------------------------------------------------------------------------
********************************************************************************************************/
module SegLed ( 
              //input 
              osc_clk        ,
              sys_rst_n      ,


              //output 
              beep           ,
              seg_c1         ,
              seg_c2         ,
              seg_c3         ,
              seg_c4         ,
              hc595_data     ,
              hc595_cs       ,
              hc595_clk  
              );

//parameter define 
parameter WIDTH2 = 26;
parameter WIDTH = 5;
parameter SIZE  = 8;

//input ports

input                    osc_clk             ;    //system clock;
input                    sys_rst_n           ;    //system reset, low is active;


//output ports
output                   beep                   ;
output                   hc595_data             ;
output                   hc595_cs               ;
output                   hc595_clk              ;

output                   seg_c1                 ;
output                   seg_c2                 ;
output                   seg_c3                 ;
output                   seg_c4                 ;


//reg define 
reg    [WIDTH-1:0]       counter                ;
reg    [WIDTH2-1:0]      count                  ;
reg    [SIZE-1:0]        disp_data              ;

reg    [SIZE-1:0]        dat                    ;

reg                      hc595_data             ;
reg                      hc595_cs               ;
reg                      hc595_clk              ;

reg    [21:0]            clk_cnt                ;
reg                      sys_clk                ;


//wire define 


/*******************************************************************************************************
**                              Main Program    
**  
********************************************************************************************************/
 

always @(posedge osc_clk or negedge sys_rst_n) begin 
   if (sys_rst_n ==1'b0)  
       clk_cnt <= 22'b0;
   else
       clk_cnt <= clk_cnt + 22'b1;
end
     
always @(posedge osc_clk or negedge sys_rst_n) begin 
   if (sys_rst_n ==1'b0)  
       sys_clk <= 1'b0;
   else if ( clk_cnt >= 22'd0 && clk_cnt <= 22'h1f_ffff )
       sys_clk <= 1'b1;
   else 
       sys_clk <= 1'b0;
end     
                       
always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0)  
            disp_data <= 8'b0;
        else if (disp_data >= 8'd10) 
            disp_data <= 8'b0;
        else if ( counter == 5'd28 ) 
            disp_data <= disp_data + 8'b1;
        else ;
end

always @(*) begin 
    case (disp_data)
         9        :  dat  =       8'hE6  ;   
         8        :  dat  =       8'hFE  ;    
         7        :  dat  =       8'hE0  ;   
         6        :  dat  =       8'hBE  ;   
         5        :  dat  =       8'hAE  ;   
         4        :  dat  =       8'h66  ;   
         3        :  dat  =       8'hEA  ;   
         2        :  dat  =       8'hDA  ;   
         1        :  dat  =       8'h60  ;   
         0        :  dat  =       8'hFC  ;   
         default  :  dat  =       8'h00  ;    
    endcase
end

always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0)  
            counter <= 5'b0;
        else if ( counter > 5'd28 ) 
            counter <= 5'b0;
        else
            counter <= counter + 5'b1;
end

always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0)  
            hc595_cs <= 1'b1;
        else if ((counter < 25) && (counter > 1)) 
            hc595_cs <= 1'b0;
        else
            hc595_cs <= 1'b1;
end

always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0)  
            hc595_clk <= 1'b0;
        else if ((counter == 5) | (counter == 7) | (counter == 9) | (counter == 11) |
                 (counter == 13) | (counter == 15) | (counter == 17) | (counter == 19)) 
            hc595_clk <= 1'b1;
        else if ((counter == 6) | (counter == 8) | (counter == 10) | (counter == 12) |
                 (counter == 14) | (counter == 16) | (counter == 18) | (counter == 20)) 
            hc595_clk <= 1'b0;
       else      
            hc595_clk <= 1'b0;
end

always @(*) begin 
    case (counter)
         5 ,6     :   hc595_data  =  dat[0]     ;
         7 ,8     :   hc595_data  =  dat[1]     ;
         9 ,10    :   hc595_data  =  dat[2]     ;
         11,12    :   hc595_data  =  dat[3]     ;
         13,14    :   hc595_data  =  dat[4]     ;
         15,16    :   hc595_data  =  dat[5]     ;
         17,18    :   hc595_data  =  dat[6]     ;
         19,20    :   hc595_data  =  dat[7]     ;
         default  :   hc595_data  =  1'b0       ;    
    endcase
end

assign beep       = 1'b1;

assign seg_c1 = 1'b1;
assign seg_c2 = 1'b1;
assign seg_c3 = 1'b1;
assign seg_c4 = 1'b0;

endmodule
//end of RTL code                       
