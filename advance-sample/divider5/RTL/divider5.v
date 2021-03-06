/****************************************Copyright (c)**************************************************
**                                      Dongdong   Studio 
**                                     
**---------------------------------------File Info-----------------------------------------------------
** File name:			divider5
** Last modified Date:	2009-10-18
** Last Version:		1.0
** Descriptions:		divider to 1/5 clock
**------------------------------------------------------------------------------------------------------
** Created by:		    dongdong
** Created date:		2009-10-18
** Version:				1.0
** Descriptions:		The original version
**
**------------------------------------------------------------------------------------------------------
** Modified by:			
** Modified date:		
** Version:				
** Descriptions:		
**
**------------------------------------------------------------------------------------------------------
********************************************************************************************************/
module divider5 ( 
              //input 
			  sys_clk,
		      sys_rst_n,


              //output 
              clk_divider5

              );

//input ports

input                    sys_clk;      //system clock;
input                    sys_rst_n;    //system reset, low is active;


//output ports
output                   clk_divider5;


//reg define 

reg    [2:0]             counter;

reg                      sigal_b;
reg                      sigal_c;

//wire define 

wire                     clk_divider5;

//parameter define 
parameter WIDTH = 8;
parameter SIZE  = 8;

/*******************************************************************************************************
**                              Main Program    
**  
********************************************************************************************************/

always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0) begin 
            counter <= 3'd0;
        end
        else if (counter == 3'd5) begin
            counter <= 3'd0;
        end
        else
            counter  <= counter +3'd1;
end

always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0) begin 
            sigal_b <= 1'b0;
        end
        else if ((counter <= 3'd1) && (counter >= 3'd0))
            sigal_b  <= 1'b1;
        else 
            sigal_b  <= 1'b0;
end

always @(negedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0) begin 
            sigal_c <= 1'b0;
        end
        else 
            sigal_c  <= sigal_b;
end

assign clk_divider5 = sigal_b |sigal_c;

endmodule
//end of RTL code                       