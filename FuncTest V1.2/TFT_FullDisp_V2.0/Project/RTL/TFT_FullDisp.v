/****************************************Copyright (c)**************************************************
**                                      Dongdong   Studio 
**                                     
**---------------------------------------File Info-----------------------------------------------------
** File name:           TFT_FullDisp
** Last modified Date:  2012-6-18
** Last Version:        1.0
** Descriptions:        TFT_FullDisp
**------------------------------------------------------------------------------------------------------
** Created by:          dongdong
** Created date:        2012-6-18
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
module TFT_FullDisp(
input                     sys_clk  ,                //osc clock input
input                     sys_rst_n,                //system reset sinal

output  wire              LCD_SCL  ,                //LCD SCL PIN
output  reg               LCD_SDA  ,                //LCD SDA PIN
output  reg               LCD_RS   ,                //LCD RS PIN, 1 is data, 0 is cmd
output  reg               LCD_CS   ,                //LCD CS PIN
output  reg               LCD_RST                   //LCD RST PIN
);           

// Prameter define

// REGs

reg                       lcd_clk           ;                
                                     
reg            [ 7:0]     ck_cnt            ;                
                                     
                                     
reg            [11:0]     delay_cnt0        ;                
reg            [11:0]     delay_cnt1        ;     
reg            [11:0]     delay_cnt2        ;                
reg            [15:0]     delay_cnt3        ;       
reg            [15:0]     delay_cnt4        ;                
                                     
                                     
reg            [ 7:0]     write_num         ;     
reg            [ 3:0]     ser_cnt           ;     
                                     
reg                       lcd_rs_init       ;     
reg                       lcd_cs_init       ;     
                                     
reg            [ 7:0]     lcd_data_init     ;     

reg                       lcd_ser_data_init ;     

reg                       lcd_cs_disp       ;   
reg                       lcd_rs_disp       ;     
  
reg                       lcd_ser_data_disp ;  


reg            [15:0]     lcd_size_cnt      ;     
reg            [ 4:0]     disp_ser_cnt      ;    
 
reg            [15:0]     lcd_data_disp     ;                

// WIREs


// ===================================
// ********** MAIN CODE **************
// ===================================

// gen a LCD 50M/256 Clock 

always @(posedge sys_clk or negedge sys_rst_n) begin
    if ( sys_rst_n == 1'b0 )
        ck_cnt <= 8'b0;
    else if ( ck_cnt == 8'd255 )
        ck_cnt <= 8'b0;
    else 
        ck_cnt <= ck_cnt + 8'b1;
end

always @(*) begin
    if  ( ck_cnt >= 8'd0 && ck_cnt <= 7'd127 ) 
        lcd_clk = 1'b0;
    else 
        lcd_clk = 1'b1;
end

// Delay cnt  

always @(posedge lcd_clk or negedge sys_rst_n) begin
    if ( sys_rst_n == 1'b0 )
        delay_cnt0 <= 12'b0;
    else if ( delay_cnt0 < 12'hfff )
        delay_cnt0 <= delay_cnt0 + 12'b1;
    else ;
end

always @(posedge lcd_clk or negedge sys_rst_n) begin
    if ( sys_rst_n == 1'b0 )
        delay_cnt1 <= 12'b0;
    else if ( delay_cnt0 == 12'hfff && delay_cnt1 < 12'hfff )
        delay_cnt1 <= delay_cnt1 + 12'b1;
    else ;
end

always @(posedge lcd_clk or negedge sys_rst_n) begin
    if ( sys_rst_n == 1'b0 )
        delay_cnt2 <= 12'b0;
    else if ( delay_cnt1 == 12'hfff && delay_cnt2 < 12'hfff )                 
        delay_cnt2 <= delay_cnt2 + 12'b1;
    else ;
end

always @(posedge lcd_clk or negedge sys_rst_n) begin
    if ( sys_rst_n == 1'b0 )
        delay_cnt3 <= 16'b0;
    else if (  delay_cnt2 == 12'hfff && delay_cnt3 < 16'hffff && write_num == 1'b1 )        // delay for > 120ms
        delay_cnt3 <= delay_cnt3 + 16'b1;
    else ;
end

// Gen LCD RESET Timing  
always @(posedge lcd_clk or negedge sys_rst_n) begin
    if ( sys_rst_n == 1'b0 )
        LCD_RST <= 1'b1;
    else if ( delay_cnt0 == 12'hfff && delay_cnt1 != 12'hfff  )
        LCD_RST <= 1'b0;
    else if ( delay_cnt1 == 12'hfff )
        LCD_RST <= 1'b1;
    else ;
end

//init wirte num Counter
always @(posedge lcd_clk or negedge sys_rst_n) begin
    if  ( sys_rst_n == 1'b0 ) 
        write_num <= 8'b1;
    else if ( write_num == 8'h1 && delay_cnt3 == 16'hffff )
        write_num <= write_num + 8'b1;
    else if ( write_num != 8'h1 && ser_cnt == 4'ha && write_num <= 8'd92 )
        write_num <= write_num + 8'b1;
    else ;
end

always @(posedge lcd_clk or negedge sys_rst_n) begin
    if  ( sys_rst_n == 1'b0 ) 
        ser_cnt <= 4'b0;
    else if ( delay_cnt3 == 16'hffff && ser_cnt == 4'ha )
        ser_cnt <= 4'b0;
    else if (  delay_cnt2 == 12'hfff && delay_cnt3 < 16'hffff && ser_cnt < 4'ha )
        ser_cnt <= ser_cnt + 4'b1;
    else if ( ser_cnt < 4'ha && delay_cnt2 == 12'hfff && write_num <= 8'd93 )
        ser_cnt <= ser_cnt + 4'b1;
    else ;
end


//init cmd and data
always @(*) begin 
    if ( write_num == 8'd1 ) begin       //cmd
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'h11;   
    end
    else if ( write_num == 8'd2 ) begin  //cmd
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'hb1;   
    end
    else if ( write_num == 8'd3 ) begin
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h01;   
    end
    else if ( write_num == 8'd4 ) begin
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h2c;   
    end
    else if ( write_num == 8'd5 ) begin
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h2d;   
    end
    else if ( write_num == 8'd6 ) begin   //cmd
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'hb2;   
    end
    else if ( write_num == 8'd7 ) begin   
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h01;   
    end
    else if ( write_num == 8'd8 ) begin   
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h2c;   
    end
    else if ( write_num == 8'd9 ) begin   
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h2d;   
    end
    else if ( write_num == 8'd10 ) begin  //cmd  
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'hb3;   
    end
    else if ( write_num == 8'd11 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h01;   
    end
    else if ( write_num == 8'd12 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h2c;   
    end
    else if ( write_num == 8'd13 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h2d;   
    end
    else if ( write_num == 8'd14 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h01;   
    end
    else if ( write_num == 8'd15 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h2c;   
    end
    else if ( write_num == 8'd16 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h2d;   
    end
    else if ( write_num == 8'd17 ) begin  //cmd  Column invelcd_rs_inition
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'hb4;   
    end
    else if ( write_num == 8'd18 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h03;   
    end
    else if ( write_num == 8'd19 ) begin  //cmd  
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'hb6;   
    end
    else if ( write_num == 8'd20 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'hb4;   
    end
    else if ( write_num == 8'd21 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'hf0;   
    end
    else if ( write_num == 8'd22 ) begin  //cmd  ST7735R Power Sequence begin
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'hc0;   
    end
    else if ( write_num == 8'd23 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'ha2;   
    end
    else if ( write_num == 8'd24 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h02;   
    end
    else if ( write_num == 8'd25 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h84;   
    end
    else if ( write_num == 8'd26 ) begin  //cmd  
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'hc1;   
    end
    else if ( write_num == 8'd27 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'hc5;   
    end
    else if ( write_num == 8'd28 ) begin  //cmd  
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'hc2;   
    end
    else if ( write_num == 8'd29 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h0a;   
    end
    else if ( write_num == 8'd30 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h00;   
    end
    else if ( write_num == 8'd31 ) begin  //cmd  
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'hc3;   
    end
    else if ( write_num == 8'd32 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h8a;   
    end
    else if ( write_num == 8'd33 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h2a;   
    end
    else if ( write_num == 8'd34 ) begin  //cmd  
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'hc4;   
    end
    else if ( write_num == 8'd35 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h8a;   
    end
    else if ( write_num == 8'd36 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'hee;   
    end                                   // End ST7735R Power Sequence
    else if ( write_num == 8'd37 ) begin  //cmd  
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'hc5;   
    end
    else if ( write_num == 8'd38 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h0a;   
    end
    else if ( write_num == 8'd39 ) begin  //cmd  
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'h36;   
    end
    else if ( write_num == 8'd40 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'hc8;   
    end
    else if ( write_num == 8'd41 ) begin  //cmd  ST7735R Gamma Sequence
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'he0 ;  
    end
    else if ( write_num == 8'd42 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h02;   
    end
    else if ( write_num == 8'd43 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h1c;   
    end
    else if ( write_num == 8'd44 ) begin    
        lcd_rs_init   = 1'h1 ; 
        lcd_data_init = 8'h07;   
    end
    else if ( write_num == 8'd45 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h12;   
    end
    else if ( write_num == 8'd46 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h37;   
    end
    else if ( write_num == 8'd47 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h32;   
    end
    else if ( write_num == 8'd48) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h29;   
    end
    else if ( write_num == 8'd49 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h2d;   
    end
    else if ( write_num == 8'd50 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h29;   
    end
    else if ( write_num == 8'd51 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h25;   
    end
    else if ( write_num == 8'd52 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h2b;   
    end
    else if ( write_num == 8'd53 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h39;   
    end
    else if ( write_num == 8'd54 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h00;   
    end
    else if ( write_num == 8'd55 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h01;   
    end
    else if ( write_num == 8'd56 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h03;   
    end
    else if ( write_num == 8'd57 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h10;   
    end
    else if ( write_num == 8'd58 ) begin  //cmd
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'he1;   
    end
    else if ( write_num == 8'd59 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h03;   
    end
    else if ( write_num == 8'd60 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h1d;   
    end
    else if ( write_num == 8'd61 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h07;   
    end
    else if ( write_num == 8'd62 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h06;   
    end
    else if ( write_num == 8'd63 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h2e;   
    end
    else if ( write_num == 8'd64 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h2c;   
    end
    else if ( write_num == 8'd65 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h29;   
    end
    else if ( write_num == 8'd66 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h2d;   
    end
    else if ( write_num == 8'd67 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h2e;   
    end
    else if ( write_num == 8'd68 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h2e;   
    end
    else if ( write_num == 8'd69 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h37;   
    end
    else if ( write_num == 8'd70 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h3f;   
    end
    else if ( write_num == 8'd71 ) begin     
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h00;   
    end
    else if ( write_num == 8'd72 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h00;   
    end
    else if ( write_num == 8'd73 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h02;   
    end
    else if ( write_num == 8'd74 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h10;   
    end                                         // End ST7735R Gamma Sequence
 
    else if ( write_num == 8'd75 ) begin        // cmd
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'h2a;   
    end
    else if ( write_num == 8'd76 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h00;   
    end                                         
     else if ( write_num == 8'd77 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h00;   
    end           
    else if ( write_num == 8'd78 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h00;   
    end           
    else if ( write_num == 8'd79 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h7f;   
    end           
    else if ( write_num == 8'd80 ) begin        // cmd
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'h2b;   
    end
    else if ( write_num == 8'd81 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h00;   
    end                                         
    else if ( write_num == 8'd82 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h00;   
    end           
    else if ( write_num == 8'd83 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h00;   
    end           
    else if ( write_num == 8'd84 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h9f;   
    end           
    else if ( write_num == 8'd85 ) begin        // cmd Enable test command
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'hf0;   
    end
    else if ( write_num == 8'd86 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h01;   
    end                
    else if ( write_num == 8'd87 ) begin        // cmd Disable ram power save mode
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'hf6;   
    end
    else if ( write_num == 8'd88 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h00;   
    end                
    else if ( write_num == 8'd89 ) begin        // cmd 65k mode
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'h3a;   
    end
    else if ( write_num == 8'd90 ) begin    
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h05;   
    end                
    else if ( write_num == 8'd91 ) begin        // cmd Display on
        lcd_rs_init   = 1'h0;   
        lcd_data_init = 8'h29;   
    end
    else begin
        lcd_rs_init   = 1'h1;   
        lcd_data_init = 8'h0;   
    end
end

// Serila output data
always @(*) begin
    if  ( ser_cnt >= 4'd1 && ser_cnt <= 4'd8 && write_num >= 8'd1 && write_num <= 8'd91 ) 
        lcd_cs_init = 1'b0;
    else 
        lcd_cs_init = 1'b1;
end

always @(*) begin
    case ( ser_cnt ) 
    4'd1 : lcd_ser_data_init = lcd_data_init[7] ;
    4'd2 : lcd_ser_data_init = lcd_data_init[6] ;
    4'd3 : lcd_ser_data_init = lcd_data_init[5] ;
    4'd4 : lcd_ser_data_init = lcd_data_init[4] ;
    4'd5 : lcd_ser_data_init = lcd_data_init[3] ;
    4'd6 : lcd_ser_data_init = lcd_data_init[2] ;
    4'd7 : lcd_ser_data_init = lcd_data_init[1] ;
    4'd8 : lcd_ser_data_init = lcd_data_init[0] ;
    default : lcd_ser_data_init = 1'b0 ;
    endcase
end

// disp tft lcd data
// Disp data Counter

always @(posedge lcd_clk or negedge sys_rst_n) begin
    if ( sys_rst_n == 1'b0 )
        delay_cnt4 <= 16'b0;
    else if (  write_num == 8'd93 && delay_cnt4 < 16'hffff )        // delay for > 120ms after display is on
        delay_cnt4 <= delay_cnt4 + 16'b1;
    else ;
end

always @(posedge lcd_clk or negedge sys_rst_n) begin
    if  ( sys_rst_n == 1'b0 ) 
        lcd_size_cnt <= 16'h0;
    else if ( delay_cnt4 == 16'hffff && disp_ser_cnt == 5'd30 && lcd_size_cnt <= 16'd20481 )
        lcd_size_cnt <= lcd_size_cnt + 16'b1;
    else ;
end

always @(posedge lcd_clk or negedge sys_rst_n) begin
    if  ( sys_rst_n == 1'b0 ) 
        disp_ser_cnt <= 5'b0;
    else if ( disp_ser_cnt == 5'd30 )
        disp_ser_cnt <= 5'b0;
    else if ( lcd_size_cnt <= 16'd20481 && write_num == 8'd93 )
        disp_ser_cnt <= disp_ser_cnt + 5'b1;
    else ;
end

// Serila output data
always @(*) begin
    if  ( lcd_size_cnt == 16'h1 && disp_ser_cnt >= 5'd1 && disp_ser_cnt <= 5'd8 ) 
        lcd_cs_disp = 1'b0;
    else if  ( lcd_size_cnt >= 16'h2 &&  lcd_size_cnt <= 16'd20481 &&  (( disp_ser_cnt >= 5'd1 && disp_ser_cnt <= 5'd8 ) || ( disp_ser_cnt >= 5'd16 && disp_ser_cnt <= 5'd24 ))) 
        lcd_cs_disp = 1'b0;
    else 
        lcd_cs_disp = 1'b1;
end

always @(*) begin
    if  ( lcd_size_cnt == 16'h1 ) 
        lcd_data_disp = 16'h2c00 ;  // cmd : wirte disp ram
    else if ( lcd_size_cnt >= 16'd2 &&  lcd_size_cnt <= 16'd4097 )
        lcd_data_disp = 16'hf800 ;  // red color 
    else if ( lcd_size_cnt >= 16'd4098 &&  lcd_size_cnt <= 16'd8193 )
        lcd_data_disp = 16'hffff ;  // white color 
    else if ( lcd_size_cnt >= 16'd8194 &&  lcd_size_cnt <= 16'd12289 )
        lcd_data_disp = 16'h07e0 ;  // green color 
    else if ( lcd_size_cnt >= 16'd12290 && lcd_size_cnt <= 16'd16385 )
        lcd_data_disp = 16'h0000 ;  // black color 
    else // if ( lcd_size_cnt >= 16'd16386 && lcd_size_cnt <= 16'd20481 )
        lcd_data_disp = 16'h001f ;  // blue color 
end

always @(*) begin
    if  ( lcd_size_cnt == 16'h1 ) 
        lcd_rs_disp = 1'b0;
    else 
        lcd_rs_disp = 1'b1;
end

always @(*) begin
    case ( disp_ser_cnt ) 
   5'd1 : lcd_ser_data_disp = lcd_data_disp[15] ;
   5'd2 : lcd_ser_data_disp = lcd_data_disp[14] ;
   5'd3 : lcd_ser_data_disp = lcd_data_disp[13] ;
   5'd4 : lcd_ser_data_disp = lcd_data_disp[12] ;
   5'd5 : lcd_ser_data_disp = lcd_data_disp[11] ;
   5'd6 : lcd_ser_data_disp = lcd_data_disp[10] ;
   5'd7 : lcd_ser_data_disp = lcd_data_disp[9] ;
   5'd8 : lcd_ser_data_disp = lcd_data_disp[8] ;
   5'd16 : lcd_ser_data_disp = lcd_data_disp[7] ;
   5'd17 : lcd_ser_data_disp = lcd_data_disp[6] ;
   5'd18 : lcd_ser_data_disp = lcd_data_disp[5] ;
   5'd19 : lcd_ser_data_disp = lcd_data_disp[4] ;
   5'd20 : lcd_ser_data_disp = lcd_data_disp[3] ;
   5'd21 : lcd_ser_data_disp = lcd_data_disp[2] ;
   5'd22 : lcd_ser_data_disp = lcd_data_disp[1] ;
   5'd23 : lcd_ser_data_disp = lcd_data_disp[0] ;

    default : lcd_ser_data_disp = 1'b0 ;
    endcase
end

// Output Process
always @(posedge lcd_clk or negedge sys_rst_n) begin
    if ( sys_rst_n == 1'b0 )
        LCD_SDA <= 1'b0;
    else 
        LCD_SDA <= lcd_ser_data_init | lcd_ser_data_disp;
end

always @(posedge lcd_clk or negedge sys_rst_n) begin
    if ( sys_rst_n == 1'b0 )
        LCD_CS <= 1'b0;
    else 
        LCD_CS <= lcd_cs_init & lcd_cs_disp;
end

always @(posedge lcd_clk or negedge sys_rst_n) begin
    if ( sys_rst_n == 1'b0 )
        LCD_RS <= 1'b0;
    else 
        LCD_RS <= lcd_rs_init & lcd_rs_disp ;   
end

assign LCD_SCL = ~lcd_clk ;

endmodule
//end of RTL code                       


