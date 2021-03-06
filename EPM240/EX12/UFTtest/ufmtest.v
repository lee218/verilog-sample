`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:    
// Design Name:    
// Module Name:    
// Project Name:   
// Target Device:  
// Tool versions:  
// Description:
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 欢迎加入EDN的FPGA/CPLD助学小组一起讨论：http://group.ednchina.com/1375/
////////////////////////////////////////////////////////////////////////////////
module ufmtest(
			databus,addr,
			nerase,nread,nwrite,
			data_valid,nbusy
		);


inout[15:0] databus;	//Flash数据总线

input[8:0] addr;		//Flash地址总线
input nerase;			//擦除Flash某一扇区信号
input nread;			//读Flash信号
input nwrite;			//写Flash信号
output data_valid;		//Flash数据输出有效信号
output nbusy;			//Flash忙信号


assign databus = nwrite ? dataout:16'hzzzz; 	//写信号有效时，Flash数据总线作为输入
assign datain = databus;	//写入Flash数据总线连接

wire[15:0] datain;		//Flash写入数据
wire[15:0] dataout;		//Flash读出数据


//例化UFM（Flash）模块
para_ufm	para_ufm_inst (
	.addr ( addr ),
	.datain ( datain ),
	.nerase ( nerase),
	.nread ( nread ),
	.nwrite ( nwrite),
	.data_valid ( data_valid ),
	.dataout ( dataout ),
	.nbusy ( nbusy )
	);



endmodule

