/****************************************Copyright (c)**************************************************
**                                      Dongdong   Studio 
**                                     
**---------------------------------------File Info-----------------------------------------------------
** File name:           e2prom_rd
** Last modified Date:  2011-11-03
** Last Version:        1.0
** Descriptions:        add note & optimize RTL code
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
module e2prom_rd ( 
              //input 
              sys_clk           ,
              sys_rst_n         ,

              sda_port          ,
              //output 
              LED               , 
              clk_sclk      
              );

//input ports

input                    sys_clk             ;    //system clock;
input                    sys_rst_n           ;    //system reset, low is active;
inout                    sda_port            ;  
 
//output ports
output                   clk_sclk            ;

output reg [7:0]         LED                 ;

//reg define 
reg    [WIDTH-1:0]       counter             ;
reg    [9:0]             counter_div         ;

reg                      clk_50k             ;
reg                      clk_200k            ;

reg                      clk_sclk            ;

reg                      sda                 ;

reg                      enable              ;

reg    [31:0]            counter_init        ;     
  
//wire define 

wire   [2:0]             device_addr         ;
wire   [7:0]             memory_addr         ;

wire                     sda_input           ;

//parameter define 
parameter WIDTH = 8;
parameter SIZE  = 8;

/*******************************************************************************************************
**                              Main Program    
**  
********************************************************************************************************/

//AT24C16 device address is 000, this value is no care ;
assign device_addr =3'b000;       //device address is 000;

// AT24C16 read addr
assign memory_addr =8'h02;        //memeory address is 02;

// counter for gen a clk_50k : need count to 1000, for 50M/1000 = 50K hz 
always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0)  
            counter_div <= 10'b0;
        else if (counter_div >= 10'd999)
            counter_div <= 10'b0;
        else
            counter_div <= counter_div + 10'b1;
end

// gen a clk_50k use counter_div :  not use counter_div 0 - 500 is for i2c bus request start timing 
always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0)  
            clk_50k <= 10'b0;
        else  if ((counter_div >= 375) && (counter_div < 875))    
            clk_50k <= 10'b1;
        else
            clk_50k <= 10'b0;
end

// counter for init for AT24C16 
always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0)  
            counter_init <= 32'h0;
        else if ( counter_init < 32'h5f5e100 ) 
            counter_init  <= counter_init + 32'b1;            
        else ;                  
end

// gen a 200K CLK for work counter count
always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0)  
            clk_200k <= 10'b0;
        else  if ((counter_div >= 0  ) && (counter_div < 125))
            clk_200k <= 10'b0;
        else  if ((counter_div >= 125) && (counter_div < 250))
            clk_200k <= 10'b1;  
        else  if ((counter_div >= 250) && (counter_div < 375))
            clk_200k <= 10'b0;                        
        else  if ((counter_div >= 375) && (counter_div < 500))
            clk_200k <= 10'b1;
        else  if ((counter_div >= 500) && (counter_div < 625))
            clk_200k <= 10'b0;
        else  if ((counter_div >= 625) && (counter_div < 750))
            clk_200k <= 10'b1;  
        else  if ((counter_div >= 750) && (counter_div < 875))
            clk_200k <= 10'b0;                        
        else  if ((counter_div >= 875) && (counter_div < 1000))
            clk_200k <= 10'b1;    
        else ;
end

// when AT24C16 init finish, work counter start to add
always @(posedge clk_200k or negedge sys_rst_n) begin 
        if (sys_rst_n ==1'b0)  
            counter <= 8'h0;
        else if ( counter_init == 32'h5f5e100 && counter < 8'hff )
            counter <= counter + 8'b1; 
        else ;    
end

//generate real clk for SCLK ,when the i2c bus is idle, make the clk wire high level
always @(*) begin 
        if ( counter >= 2 && counter <= 156 )
            clk_sclk = clk_50k;
        else  
            clk_sclk = 1'b1;
end

// output SDA data with AT24C16 data sheet request 

always @(*) begin 
    case (counter)
         0 : sda = 1'b1 ;       
         1 : sda = 1'b1 ;          
         2 : sda = 1'b1 ;       
         3 : sda = 1'b0 ;               
         4 : sda = 1'b0 ;              //SOP
             
         5 : sda = 1'b1 ;          
         6 : sda = 1'b1 ;       
         7 : sda = 1'b1 ;        
         8 : sda = 1'b1 ;               // 1
               
         9 : sda = 1'b0 ;           
        10 : sda = 1'b0 ;       
        11 : sda = 1'b0 ;               
        12 : sda = 1'b0 ;               //0
             
        13 : sda = 1'b1 ;          
        14 : sda = 1'b1 ;       
        15 : sda = 1'b1 ;             
        16 : sda = 1'b1 ;                //1
              
        17 : sda = 1'b0 ;          
        18 : sda = 1'b0 ;       
        19 : sda = 1'b0 ;                       
        20 : sda = 1'b0 ;                //0   
        
        21 : sda = device_addr[2] ;          
        22 : sda = device_addr[2] ;       
        23 : sda = device_addr[2] ;        
        24 : sda = device_addr[2] ;                
            
        25 : sda = device_addr[1] ;          
        26 : sda = device_addr[1] ;       
        27 : sda = device_addr[1] ;               
        28 : sda = device_addr[1] ;      
         
        29 : sda = device_addr[0] ;          
        30 : sda = device_addr[0] ;       
        31 : sda = device_addr[0] ;          
        32 : sda = device_addr[0] ;   
 
        33 : sda = 1'b0 ;                
        34 : sda = 1'b0 ;       
        35 : sda = 1'b0 ;          
        36 : sda = 1'b0 ;                         //presude write ,bit[0] =  0  
         
        33 + 4 : sda = 1'bz ;                
        34 + 4 : sda = 1'bz ;       
        35 + 4 : sda = 1'bz ;          
        36 + 4 : sda = 1'bz ;                     //ACK ,sda should be input 
        
        37 + 4 : sda = memory_addr[7] ;               
        38 + 4 : sda = memory_addr[7] ;       
        39 + 4 : sda = memory_addr[7] ;         
        40 + 4 : sda = memory_addr[7] ;    
           
        41 + 4: sda = memory_addr[6] ;          
        42 + 4: sda = memory_addr[6] ;       
        43 + 4: sda = memory_addr[6] ;        
        44 + 4: sda = memory_addr[6] ;      
              
        45 + 4: sda = memory_addr[5] ;          
        46 + 4: sda = memory_addr[5] ;       
        47 + 4: sda = memory_addr[5] ;               
        48 + 4: sda = memory_addr[5] ;     
                  
        49 + 4: sda = memory_addr[4] ;         
        50 + 4: sda = memory_addr[4] ;       
        51 + 4: sda = memory_addr[4] ;          
        52 + 4: sda = memory_addr[4] ;
                  
        53 + 4: sda = memory_addr[3] ;        
        54 + 4: sda = memory_addr[3] ;       
        55 + 4: sda = memory_addr[3] ;          
        56 + 4: sda = memory_addr[3] ; 
              
        57 + 4: sda = memory_addr[2] ;               
        58 + 4: sda = memory_addr[2] ;       
        59 + 4: sda = memory_addr[2] ;         
        60 + 4: sda = memory_addr[2] ; 
                 
        61 + 4: sda = memory_addr[1] ;          
        62 + 4: sda = memory_addr[1] ;       
        63 + 4: sda = memory_addr[1] ;        
        64 + 4: sda = memory_addr[1] ; 
              
        65 + 4: sda = memory_addr[0] ;          
        66 + 4: sda = memory_addr[0] ;       
        67 + 4: sda = memory_addr[0] ;               
        68 + 4: sda = memory_addr[0] ;       
              
        69 + 4: sda = 1'b0 ;         
        70 + 4: sda = 1'b0 ;       
        71 + 4: sda = 1'b0 ;          
        72 + 4: sda = 1'b0 ;                     //ACK 
             
        73 + 4: sda = 1'b1 ;                
        74 + 4: sda = 1'b1 ;      
         
        75 + 4: sda = 1'b0 ;          
        76 + 4: sda = 1'b0 ;                     //SOP
        
        77 + 4: sda = 1'b1 ;                      
        78 + 4: sda = 1'b1 ;       
        79 + 4: sda = 1'b1 ;         
        80 + 4: sda = 1'b1 ; 
              
        81 + 4: sda = 1'b0 ;          
        82 + 4: sda = 1'b0 ;       
        83 + 4: sda = 1'b0 ;        
        84 + 4: sda = 1'b0 ;  
             
        85 + 4: sda = 1'b1 ;                  
        86 + 4: sda = 1'b1 ;       
        87 + 4: sda = 1'b1 ;               
        88 + 4: sda = 1'b1 ; 
              
        89 + 4: sda = 1'b0 ;        
        90 + 4: sda = 1'b0 ;       
        91 + 4: sda = 1'b0 ;          
        92 + 4: sda = 1'b0 ;  
             
        93 + 4: sda = device_addr[2] ;                
        94 + 4: sda = device_addr[2] ;       
        95 + 4: sda = device_addr[2] ;          
        96 + 4: sda = device_addr[2] ;  
             
        97 + 4: sda = device_addr[1]  ;               
        98 + 4: sda = device_addr[1]  ;       
        99 + 4: sda = device_addr[1]  ;        
       100 + 4: sda = device_addr[1]  ; 
             
       101 + 4: sda = device_addr[0]  ;          
       102 + 4: sda = device_addr[0]  ;       
       103 + 4: sda = device_addr[0]  ;        
       104 + 4: sda = device_addr[0]  ;          
       
       105 + 4: sda = 1'b1 ;                              
       106 + 4: sda = 1'b1 ;                              
       107 + 4: sda = 1'b1 ;                              
       108 + 4: sda = 1'b1 ;                          //Read Enable  1 
                    
       105 + 4+ 4: sda = 1'b0 ;                 
       106 + 4+ 4: sda = 1'b0 ;       
       107 + 4+ 4: sda = 1'b0 ;               
       108 + 4+ 4: sda = 1'b0 ;                       //ACK
       
       109 + 4+ 4: sda = 1'b0 ;        
       110 + 4+ 4: sda = 1'b0 ;       
       111 + 4+ 4: sda = 1'b0 ;          
       112 + 4+ 4: sda = 1'b0 ;                      //DATA[7]
           
       113 + 4+ 4: sda = 1'b0 ;        
       114 + 4+ 4: sda = 1'b0 ;       
       115 + 4+ 4: sda = 1'b0 ;          
       116 + 4+ 4: sda = 1'b0 ;                      //DATA[6] 
                 
       117 + 4+ 4: sda = 1'b0 ;               
       118 + 4+ 4: sda = 1'b0 ;       
       119 + 4+ 4: sda = 1'b0 ;       
       120 + 4+ 4: sda = 1'b0 ;                      //DATA[5] 
             
       121 + 4+ 4: sda = 1'b0 ;          
       122 + 4+ 4: sda = 1'b0 ;       
       123 + 4+ 4: sda = 1'b0 ;        
       124 + 4+ 4: sda = 1'b0 ;                      //DATA[4] 
                                                           
       125 + 4+ 4: sda = 1'b0 ;                               
       126 + 4+ 4: sda = 1'b0 ;                               
       127 + 4+ 4: sda = 1'b0 ;                               
       128 + 4+ 4: sda = 1'b0 ;                      //DATA[3]
                                                        
       129 + 4+ 4: sda = 1'b0 ;                               
       130 + 4+ 4: sda = 1'b0 ;                               
       131 + 4+ 4: sda = 1'b0 ;                               
       132 + 4+ 4: sda = 1'b0 ;                      //DATA[2]
                 
       133 + 4+ 4: sda = 1'b0 ;      
       134 + 4+ 4: sda = 1'b0 ;     
       135 + 4+ 4: sda = 1'b0 ;        
       136 + 4+ 4: sda = 1'b0 ;                      //DATA[1]                                                        
              
       137 + 4+ 4: sda = 1'b1 ;                               
       138 + 4+ 4: sda = 1'b1 ;                               
       139 + 4+ 4: sda = 1'b1 ;                                 
       140 + 4+ 4: sda = 1'b1 ;                      //DATA[0]  
                                                         
       141 + 4+ 4: sda = 1'b0 ;                               
       142 + 4+ 4: sda = 1'b0 ;                               
       143 + 4+ 4: sda = 1'b0 ;                               
       144 + 4+ 4: sda = 1'b0 ;                      //NON ACK
       
       145 + 4+ 4: sda = 1'b0 ; 
       146 + 4+ 4: sda = 1'b0 ; 
       
       147 + 4+ 4: sda = 1'b1 ; 
       148 + 4+ 4: sda = 1'b1 ; 
       149 + 4+ 4: sda = 1'b1 ;                       //EOP
       default :  sda = 1'b1 ;   
   endcase    
end

// output SDA data enable with AT24C16 data sheet request 

always @(*) begin 
    case (counter)   
        // 0 : sda = 1'b1 ;       
         1 : enable = 1'b1 ;           
         2 : enable = 1'b1 ;        
         3 : enable = 1'b1 ;                
         4 : enable = 1'b1 ;                //SOP
             
         5 : enable = 1'b1 ;            
         6 : enable = 1'b1 ;         
         7 : enable = 1'b1 ;          
         8 : enable = 1'b1 ;                 // 1
               
         9 :enable = 1'b1 ;            
        10 :enable = 1'b1 ;        
        11 :enable = 1'b1 ;                
        12 :enable = 1'b1 ;                 //0
             
        13 : enable = 1'b1 ;           
        14 : enable = 1'b1 ;        
        15 : enable = 1'b1 ;              
        16 : enable = 1'b1 ;                 //1
              
        17 : enable = 1'b1 ;          
        18 : enable = 1'b1 ;       
        19 : enable = 1'b1 ;                       
        20 : enable = 1'b1 ;                 //0   
        
        21 : enable = 1'b1 ;            
        22 : enable = 1'b1 ;         
        23 : enable = 1'b1 ;          
        24 : enable = 1'b1 ;                  
            
        25 : enable = 1'b1 ;           
        26 : enable = 1'b1 ;        
        27 : enable = 1'b1 ;                
        28 : enable = 1'b1 ;       
         
        29 : enable = 1'b1 ;            
        30 : enable = 1'b1 ;         
        31 : enable = 1'b1 ;            
        32 : enable = 1'b1 ;     
 
        33 : enable = 1'b1 ;                 
        34 : enable = 1'b1 ;        
        35 : enable = 1'b1 ;           
        36 : enable = 1'b1 ;                    //presude write ,bit[0] =  0  
         
//        33 + 4 : sda = 1'bz ;                
//        34 + 4 : sda = 1'bz ;       
//        35 + 4 : sda = 1'bz ;          
//        36 + 4 : sda = 1'bz ;                 //ACK ,sda should be input 
        
        37 + 4 : enable = 1'b1 ;                 
        38 + 4 : enable = 1'b1 ;         
        39 + 4 : enable = 1'b1 ;           
        40 + 4 : enable = 1'b1 ;      
           
        41 + 4: enable = 1'b1 ;            
        42 + 4: enable = 1'b1 ;         
        43 + 4: enable = 1'b1 ;          
        44 + 4: enable = 1'b1 ;        
              
        45 + 4:enable = 1'b1 ;         
        46 + 4:enable = 1'b1 ;      
        47 + 4:enable = 1'b1 ;              
        48 + 4:enable = 1'b1 ;    
                  
        49 + 4:enable = 1'b1 ;          
        50 + 4:enable = 1'b1 ;        
        51 + 4:enable = 1'b1 ;           
        52 + 4:enable = 1'b1 ;  
                  
        53 + 4: enable = 1'b1 ;        
        54 + 4: enable = 1'b1 ;       
        55 + 4: enable = 1'b1 ;          
        56 + 4: enable = 1'b1 ;  
              
        57 + 4: enable = 1'b1 ;              
        58 + 4: enable = 1'b1 ;      
        59 + 4: enable = 1'b1 ;        
        60 + 4: enable = 1'b1 ;  
                 
        61 + 4: enable = 1'b1 ;           
        62 + 4: enable = 1'b1 ;        
        63 + 4: enable = 1'b1 ;         
        64 + 4: enable = 1'b1 ;  
              
        65 + 4: enable = 1'b1 ;           
        66 + 4: enable = 1'b1 ;        
        67 + 4: enable = 1'b1 ;                
        68 + 4: enable = 1'b1 ;        
              
        //69 + 4: sda = 1'b0 ;         
        //70 + 4: sda = 1'b0 ;       
        //71 + 4: sda = 1'b0 ;          
        //72 + 4: sda = 1'b0 ;                     //ACK 
             
        73 + 4: enable = 1'b1 ;                
        74 + 4: enable = 1'b1 ;      
         
        75 + 4: enable = 1'b1 ;          
        76 + 4: enable = 1'b1 ;                     //SOP
        
        77 + 4: enable = 1'b1 ;                      
        78 + 4: enable = 1'b1 ;       
        79 + 4: enable = 1'b1 ;         
        80 + 4: enable = 1'b1 ; 
              
        81 + 4: enable = 1'b1 ;          
        82 + 4: enable = 1'b1 ;       
        83 + 4: enable = 1'b1 ;        
        84 + 4: enable = 1'b1 ;  
             
        85 + 4: enable = 1'b1 ;                   
        86 + 4: enable = 1'b1 ;        
        87 + 4: enable = 1'b1 ;                
        88 + 4: enable = 1'b1 ;  
              
        89 + 4: enable = 1'b1 ;       
        90 + 4: enable = 1'b1 ;      
        91 + 4: enable = 1'b1 ;         
        92 + 4: enable = 1'b1 ; 
             
        93 + 4: enable = 1'b1 ;                 
        94 + 4: enable = 1'b1 ;        
        95 + 4: enable = 1'b1 ;           
        96 + 4: enable = 1'b1 ;   
             
        97 + 4: enable = 1'b1 ;               
        98 + 4: enable = 1'b1 ;       
        99 + 4: enable = 1'b1 ;        
       100 + 4: enable = 1'b1 ; 
             
       101 + 4: enable = 1'b1 ;          
       102 + 4: enable = 1'b1 ;       
       103 + 4: enable = 1'b1 ;        
       104 + 4: enable = 1'b1 ;          
       
       105 + 4: enable = 1'b1 ;                             
       106 + 4: enable = 1'b1 ;                             
       107 + 4: enable = 1'b1 ;                             
       108 + 4: enable = 1'b1 ;                      //Read Enable  1 
                    

       145 + 4+ 4:enable = 1'b1 ;
       146 + 4+ 4:enable = 1'b1 ;
       
       147 + 4+ 4: enable = 1'b1 ;
       148 + 4+ 4: enable = 1'b1 ;
       149 + 4+ 4: enable = 1'b1 ;                    //EOP

       default : enable = 1'b0 ;    
   endcase    
end

// output sda data when sda enable is 1, else output Z state
assign sda_port = (enable == 1'b1)?  sda : 1'bz;

// disp read data to the led when read 
always @(posedge sys_clk or negedge sys_rst_n) begin 
    if (sys_rst_n ==1'b0)  
        LED <= 8'h0;
    else     
        case (counter)     
           111+4+ 4     : LED[7] = sda_port ;           //DATA[7]     
           115+4+ 4     : LED[6] = sda_port ;           //DATA[6]        
           119+4+ 4     : LED[5] = sda_port ;           //DATA[5]        
           123+4+ 4     : LED[4] = sda_port ;           //DATA[4]                                                  
           127+4+ 4     : LED[3] = sda_port ;           //DATA[3]
           131+4+ 4     : LED[2] = sda_port ;           //DATA[2]                                                             
           135+4+ 4     : LED[1] = sda_port ;           //DATA[1]                                  
           139+4+ 4     : LED[0] = sda_port ;           //DATA[0]                        
           default : LED    = LED     ;    
        endcase   
end

endmodule

//end of RTL code                       