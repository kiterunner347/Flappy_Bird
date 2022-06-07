`timescale  1ns/1ns

module  hdmi_colorbar
(
    input   wire            sys_clk     ,   //输入工作时钟,频率50MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效
    input   wire    [3:0]   data_in     ,   //输入按键
    
    output  wire            ddc_scl     ,
    output  wire            ddc_sda     ,
    output  wire            tmds_clk_p  ,
    output  wire            tmds_clk_n  ,   //HDMI时钟差分信号
    output  wire    [2:0]   tmds_data_p ,
    output  wire    [2:0]   tmds_data_n ,   //HDMI图像差分信号
    output  wire    [5:0]   sel         ,   //数码管位选信号
    output  wire    [7:0]   seg             //数码管段选信号

);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire define
wire            vga_clk ;   //VGA工作时钟,频率25MHz
wire            clk_5x  ;
wire            locked  ;   //PLL locked信号
wire            rst_n   ;   //VGA模块复位信号
wire            key_flag;
wire    [11:0]  pix_x   ;   //VGA有效显示区域X轴坐标
wire    [11:0]  pix_y   ;   //VGA有效显示区域Y轴坐标
wire    [15:0]  pix_data;   //VGA像素点色彩信息
wire            hsync   ;   //输出行同步信号
wire            vsync   ;   //输出场同步信号
wire    [15:0]  rgb     ;   //输出像素信息
wire            rgb_valid;
wire    [19:0]  score   ;

//rst_n:VGA模块复位信号
assign  rst_n   = (sys_rst_n & (locked));
assign  ddc_scl = 1'b1;
assign  ddc_sda = 1'b1;
//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

clk_wiz_0 clk_wiz_0_inst
(
    .reset      (~sys_rst_n ),  //输入复位信号,高电平有效,1bit
    .clk_in1    (sys_clk    ),  //输入50MHz晶振时钟,1bit

    .clk_out1   (vga_clk    ), //输出VGA工作时钟,频率25Mhz,1bit
    .clk_out2   (clk_5x     ), //输出hdmi工作时钟,频率125M,1bit
    .locked     (locked     )  //输出pll locked信号,1bit
);

//vga模块是为了生成图像，实际显示为HDMI
//------------- vga_ctrl_inst -------------
vga_ctrl  vga_ctrl_inst
(
    .vga_clk    (vga_clk    ),  //输入工作时钟,频率25MHz,1bit
    .sys_rst_n  (rst_n      ),  //输入复位信号,低电平有效,1bit
    .pix_data   (pix_data   ),  //输入像素点色彩信息,16bit

    .pix_x      (pix_x      ),  //输出VGA有效显示区域像素点X轴坐标,10bit
    .pix_y      (pix_y      ),  //输出VGA有效显示区域像素点Y轴坐标,10bit
    .hsync      (hsync      ),  //输出行同步信号,1bit
    .vsync      (vsync      ),  //输出场同步信号,1bit
    .rgb_valid  (rgb_valid  ),
    .rgb        (rgb        )   //输出像素点色彩信息,16bit
);

key_filter key_filter_inst
(
    .sys_clk     (sys_clk   ),   //系统时钟50Mhz
    .sys_rst_n   (sys_rst_n ),   //全局复位
    .key_in      (key       ),   //按键输入信号
    
    .key_flag    (key_flag  )   //key_flag为1时表示消抖后检测到按键被按下
                                    //key_flag为0时表示没有检测到按键被按下
);

//------------- vga_pic_inst -------------
vga_pic vga_pic_inst
(
    .vga_clk    (vga_clk    ),  //输入工作时钟,频率25MHz,1bit
    .sys_rst_n  (rst_n      ),  //输入复位信号,低电平有效,1bit
    .pix_x      (pix_x      ),  //输入VGA有效显示区域像素点X轴坐标,10bit
    .pix_y      (pix_y      ),  //输入VGA有效显示区域像素点Y轴坐标,10bit
    .data_in    (data_in    ),
    
    .pix_data   (pix_data   ),  //输出像素点色彩信息,16bit
    .score      (score      )
);

//------------- hdmi_ctrl_inst -------------
hdmi_ctrl   hdmi_ctrl_inst
(
    .clk_1x      (vga_clk           ),   //输入系统时钟
    .clk_5x      (clk_5x            ),   //输入5倍系统时钟
    .sys_rst_n   (rst_n             ),   //复位信号,低有效
    .rgb_blue    ({rgb[4:0],3'b0}   ),   //蓝色分量
    .rgb_green   ({rgb[10:5],2'b0}  ),   //绿色分量
    .rgb_red     ({rgb[15:11],3'b0} ),   //红色分量
    .hsync       (hsync             ),   //行同步信号
    .vsync       (vsync             ),   //场同步信号
    .de          (rgb_valid         ),   //使能信号
    .hdmi_clk_p  (tmds_clk_p        ),
    .hdmi_clk_n  (tmds_clk_n        ),   //时钟差分信号
    .hdmi_r_p    (tmds_data_p[2]    ),
    .hdmi_r_n    (tmds_data_n[2]    ),   //红色分量差分信号
    .hdmi_g_p    (tmds_data_p[1]    ),
    .hdmi_g_n    (tmds_data_n[1]    ),   //绿色分量差分信号
    .hdmi_b_p    (tmds_data_p[0]    ),
    .hdmi_b_n    (tmds_data_n[0]    )    //蓝色分量差分信号
);

seg_dynamic seg_dynamic_inst
(
    .sys_clk     (sys_clk  ),   //系统时钟，频率50MHz
    .sys_rst_n   (sys_rst_n),   //复位信号，低有效
    .data        (score    ),   //数码管要显示的值
    .point       (6'b000000),   //小数点显示,高电平有效
    .seg_en      (1        ),   //数码管使能信号，高电平有效
    .sign        (0        ),   //符号位，高电平显示负号

    .sel         (sel      ),   //数码管位选信号
    .seg         (seg      )    //数码管段选信号

);

endmodule
