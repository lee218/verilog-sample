/****************************************Copyright (c)**************************************************
**                                      Dongdong   Studio 
**                                     
**---------------------------------------File Info-----------------------------------------------------
** File name:			PWM
** Last modified Date:	2009-10-18
** Last Version:		1.0
** Descriptions:		PWM to LED
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
** Descriptions: duty_cycle can assign to the SW bit to bit; 		
**
**------------------------------------------------------------------------------------------------------
********************************************************************************************************/
module PWM ( 
              //input 
			  sys_clk,
		      sys_rst_n,
              duty_cycle,

              //output 
              led
              );

//input ports

input                    sys_clk;      //system clock;
input                    sys_rst_n;    //system reset, low is active;
input  [WIDTH-1:0]       duty_cycle;

//output ports
output                   led;

//reg define 

reg                      pwm_out;
reg [15:0]               counter;
//wire define 

wire                     led    ;
//parameter define 
parameter WIDTH = 4;
parameter SIZE  = 8;

/*******************************************************************************************************
**                              Main Program    
**  
********************************************************************************************************/

always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0) begin 
            counter <= 16'b0;
        end
        else 
            counter  <= counter + 16'b1;
end

always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0) begin 
            pwm_out <= 8'b0;
        end
        else if (counter[15:12] <= duty_cycle)  
            pwm_out  <= 1'b1;
        else 
            pwm_out  <= 1'b0;
end


assign led = pwm_out;

endmodule
//end of RTL code                       