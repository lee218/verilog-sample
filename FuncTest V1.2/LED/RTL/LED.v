/****************************************Copyright (c)**************************************************
**                                      Dongdong   Studio 
**                                     
**---------------------------------------File Info-----------------------------------------------------
** File name:           LED
** Last modified Date:  2012-7-8
** Last Version:        1.1
** Descriptions:        LED
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
module LED ( 
                  //input 
input             sys_clk             ,    //system clock;
input             sys_rst_n           ,    //system reset, low is active;

                  //output 
output reg [7:0]  LED                 
              );


//Parameter define 
parameter WIDTH = 8                          ;
parameter SIZE  = 8                          ;

parameter WIDTH2 = 18                        ;

parameter Para = 100000;

//Reg define 
reg    [SIZE-1:0]        counter             ;
reg    [WIDTH2-1:0]      count               ;

//Wire define 



//************************************************************************************
//**                              Main Program    
//**  
//************************************************************************************

// count for add counter 
always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0) 
            count <= 18'b0;
        else  
            count <= count + 18'b1;
end

// counter for delay time to LED display
always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0)  
            counter <= 8'b0;
        else if ( count == Para) 
            counter  <= counter + 8'b1;
        else ;
end

// ctrl LED pipeline display when counter is equal 10 or 20 ....
always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0) 
            LED <= 8'b0;
        else begin
            case (counter) 
                 8'd10     : LED <= 8'b10000000   ;
                 8'd20     : LED <= 8'b01000000   ;
                 8'd30     : LED <= 8'b00100000   ;
                 8'd40     : LED <= 8'b00010000   ;
                 8'd50     : LED <= 8'b00001000   ;
                 8'd60     : LED <= 8'b00000100   ;
                 8'd70     : LED <= 8'b00000010   ;
                 8'd80     : LED <= 8'b00000001   ;   
                 default   : LED <= 8'b00000000   ;   
            endcase
        end          
end

endmodule
//end of RTL code                       