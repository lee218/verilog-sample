/****************************************Copyright (c)**************************************************
**                                      Dongdong   Studio 
**                                     
**---------------------------------------File Info-----------------------------------------------------
** File name:			key_debounce
** Last modified Date:	2009-10-18
** Last Version:		1.0
** Descriptions:		key to debounce
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
module counter4( 
					//input 
					sys_clk,
					sys_rst_n,
					ena,

				    //output 
					dout,
					cout
                    );

//input ports

input                    sys_clk;      //system clock;
input                    sys_rst_n;    //system reset, low is active;
input                    ena;          //

//output ports
output [WIDTH-1:0]             dout;
output                         cout;
//reg define 
reg    [WIDTH-1:0]             counter;

//wire define 


//parameter define 
parameter WIDTH = 4;

/*******************************************************************************************************
**                              Main Program    
**  
********************************************************************************************************/

always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0) begin 
            counter <= 1'b0;
        end
        else if (ena == 1'b1) begin 
            counter <= counter + 1'b1;
        end
end

assign cout = &counter;
assign dout = counter;

endmodule
//end of RTL code                       