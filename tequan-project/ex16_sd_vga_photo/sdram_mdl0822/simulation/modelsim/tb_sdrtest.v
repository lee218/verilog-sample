//testbench for vgasdram


`timescale 1ns/1ns


module tb_sdrtest;

//print_task.v里包含常用信息打印任务封装
print_task	print();

//sys_ctrl_task.v里包含系统时钟产生单元和系统复位任务
sys_ctrl_task	sys_ctrl(
						.clk(clk),
						.rst_n(rst_n)
					);
					
	//input				
wire clk;		//系统时钟,25MHz
wire rst_n;		//复位信号，低电平有效

	//output
	// FPGA与SDRAM硬件接口
wire sdram_clk;				// SDRAM时钟信号
wire sdram_cke;				// SDRAM时钟有效信号
wire sdram_cs_n;			// SDRAM片选信号
wire sdram_ras_n;			// SDRAM行地址选通脉冲
wire sdram_cas_n;			// SDRAM列地址选通脉冲
wire sdram_we_n;			// SDRAM写允许位
wire[1:0] sdram_ba;			// SDRAM的L-Bank地址线
wire[11:0] sdram_addr;		// SDRAM地址总线
//wire rs232_tx;				// 串口数据发送

//inout
wire[15:0] sdram_data;		// SDRAM数据总线

	// SD硬件接口
reg spi_miso;		//SPI主机输入从机输出数据信号
wire spi_mosi;	//SPI主机输出从机输入数据信号
wire spi_clk;		//SPI时钟信号，由主机产生
wire spi_cs_n;	//SPI从设备使能信号，由主设备控制

	// FPGA与VGA接口信号
wire hsync;	//行同步信号
wire vsync;	//场同步信号
wire[1:0] vga_r;
wire[2:0] vga_g;
wire[2:0] vga_b;

sdr_test	sd(
			.clk(clk),
			.rst_n(rst_n),
			.sdram_clk(sdram_clk),
			.sdram_cke(sdram_cke),
			.sdram_cs_n(sdram_cs_n),
			.sdram_ras_n(sdram_ras_n),
			.sdram_cas_n(sdram_cas_n),
			.sdram_we_n(sdram_we_n),
			.sdram_ba(sdram_ba),
			.sdram_addr(sdram_addr),
			.sdram_data(sdram_data),
			.spi_miso(spi_miso),
			.spi_mosi(spi_mosi),
			.spi_clk(spi_clk),
			.spi_cs_n(spi_cs_n),
			.hsync(hsync),
			.vsync(vsync),
			.vga_r(vga_r),
			.vga_g(vga_g),
			.vga_b(vga_b)

		);


reg[15:0] sdram_datar;
reg sdatalink;				
assign sdram_data = sdatalink ? sdram_datar:16'hzzzz;

//integer write_232rx_file;	//定义文件指针	
//integer cnt512;			//512计数

initial begin
		//串口数据接收文件初始化
//	write_232rx_file = $fopen("write_232rx_file.txt");//txt文件初始化
//	$fdisplay(write_232rx_file,"rx232 receive data display:\n");
//	cnt512 = 0;
	spi_miso = 1;
	sdatalink = 0;
		//SDRAM输入接口初始化
	//sdatalink = 0;

		//系统复位
	sys_ctrl.sys_reset(400);	//有效复位400ns

	#200_000;	//等待200us

	//sdram_wr_task;
	#20_000;	//等待30us
	//sdram_rd_task;

		//等待，系统测试完成
	#30_000_000;		//等待30ms	
	print.terminate;		
end


//模拟sdram存储写入数据
reg[15:0] memd[7:0];	//256个16bit缓存
integer cntwr;
always @(posedge sdram_clk) begin
	if({sdram_cke,sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} == 5'b10011) begin	//行选通
		@(posedge sdram_clk); 
		@(posedge sdram_clk); 
		if({sdram_cke,sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} == 5'b10100) begin	//写命令
			for(cntwr=0;cntwr<8;cntwr=cntwr+1) begin
				memd[cntwr] = sdram_data;
				@(posedge sdram_clk);
			end	
		end
	end
end


//模拟sdram在数据读时将数据送出
integer cntrd;
always @(posedge sdram_clk) begin
	if({sdram_cke,sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} == 5'b10011) begin	//行选通
		@(posedge sdram_clk); 
		@(posedge sdram_clk); 
		if({sdram_cke,sdram_cs_n,sdram_ras_n,sdram_cas_n,sdram_we_n} == 5'b10101) begin	//读命令
			@(posedge sdram_clk); 
			@(posedge sdram_clk); 
			sdatalink = 1'b1;
			for(cntrd=0;cntrd<8;cntrd=cntrd+1) begin
				#2;
				sdram_datar = memd[cntrd];
				@(posedge sdram_clk);
			end
			@(posedge sdram_clk);
			sdatalink = 1'b0;	
		end
	end
end

/*
//模拟串口接收
integer cntbit;		
reg[7:0] rxdata;	//串口接收数据寄存器
parameter	BPS9600		= 104_167;		//9600bps传输率
parameter	BPS9600_2	= 52_083;		//9600bps传输率
always @(negedge rs232_tx) begin
	if(!rs232_tx) begin
		#BPS9600;		//起始位等待
		#BPS9600_2;		//对齐数据中间
		for(cntbit=0;cntbit<8;cntbit=cntbit+1) begin	//采样8bit数据
			rxdata[cntbit] = rs232_tx;
			#BPS9600;		//等待下一位
		end
		if(!rs232_tx) print.error("rs232_tx stop bit error");	//结束位出错报告
		else #BPS9600_2;		//等待结束位完成
		$fdisplay(write_232rx_file,"Receive data %d  :  %d\n",cnt512,rxdata);		//将当前接收到的串口数据输出到write_232rx_file.txt中
		$write("current receive data is %d\n",rxdata);
		cnt512 = cnt512+1;
	end
	
end
*/

//模拟sd命令接收
integer i;
reg[9:0] j;
reg[7:0] rx_cmd;
reg[31:0] rx_arg;
reg[7:0] rx_crc;
always @(negedge spi_cs_n) begin	//模拟SD从机
	//接收8位cmd
	for(i=0;i<8;i=i+1) begin	
		@(posedge spi_clk); #2;
		rx_cmd[7-i] = spi_mosi;
	end
	//接收32位arg
	for(i=0;i<32;i=i+1) begin	
		@(posedge spi_clk); #2;
		rx_arg[31-i] = spi_mosi;
	end
	//接收8位CRC
	for(i=0;i<8;i=i+1) begin	
		@(posedge spi_clk); #2;
		rx_crc[7-i] = spi_mosi;
	end		
	//8CLK wait
	for(i=0;i<8;i=i+1) begin	
		@(posedge spi_clk); #2;
	end		
	//不同的响应
	if(rx_cmd[5:0] == 6'd0) begin		//CMD0响应
			//8CLK wait test
			repeat(10) begin
				for(i=0;i<8;i=i+1) begin	
					@(posedge spi_clk); #2;
				end		
			end
		for(i=0;i<8;i=i+1) begin	//respone
			@(negedge spi_clk); #2;
			if(i==7) spi_miso = 1'b1;	//CMD0响应0x01
			else spi_miso = 1'b0;
		end		
	end
	else begin	//其它响应
		for(i=0;i<8;i=i+1) begin	//respone
			@(negedge spi_clk); #2;
			spi_miso = 1'b0;
		end
	end

	//读数据命令
	if(rx_cmd[5:0] == 6'd17) begin	
		//8CLK wait
		@(posedge spi_clk); #2;		
		for(i=0;i<8;i=i+1) begin	
			@(posedge spi_clk); #2;	
		end
		//CMD17读数据命令起始字节
		for(i=0;i<8;i=i+1) begin	
			@(negedge spi_clk); #2;
			if(i==7) spi_miso = 1'b0;	//CMD17响应0xfe
			else spi_miso = 1'b1;
		end
		//512B数据读取
		for(j=512;j>0;j=j-1) begin
			for(i=0;i<8;i=i+1) begin	
				@(negedge spi_clk); #2;
					spi_miso = j[7-i];
			end
		end
	end	
	
	@(posedge spi_clk); #2;	//over
	for(i=0;i<8;i=i+1) begin	//8CLK wait
		@(posedge spi_clk); #2;
	end
	spi_miso = 1'b1;
			
end


endmodule

