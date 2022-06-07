`timescale  1ns/1ns
////////////////////////////////////////////////////////////////////////
// Author  : EmbedFire
// 实验平台: 野火FPGA系列开发板
// 公司    : http://www.embedfire.com
// 论坛    : http://www.firebbs.cn
// 淘宝    : https://fire-stm32.taobao.com
////////////////////////////////////////////////////////////////////////

module  tb_hdmi_colorbar();
//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//wire  define

wire            ddc_scl     ;
wire            ddc_sda     ;
wire            tmds_clk_p  ;
wire            tmds_clk_n  ;
wire    [2:0]   tmds_data_p ;
wire    [2:0]   tmds_data_n ;

//reg   define
reg             sys_clk     ;
reg             sys_rst_n   ;

//********************************************************************//
//**************************** Clk And Rst ***************************//
//********************************************************************//

//sys_clk,sys_rst_n初始赋值
initial
    begin
        sys_clk     =   1'b1;
        sys_rst_n   <=  1'b0;
        #200
        sys_rst_n   <=  1'b1;
    end

//sys_clk：产生时钟
always  #10 sys_clk = ~sys_clk  ;

//********************************************************************//
//*************************** Instantiation **************************//
//********************************************************************//

//------------- vga_colorbar_inst -------------
hdmi_colorbar    hdmi_colorbar_inst
(
    .sys_clk    (sys_clk    ),  //输入晶振时钟,频率50MHz,1bit
    .sys_rst_n  (sys_rst_n  ),  //输入复位信号,低电平有效,1bit
    
    .ddc_scl    (ddc_scl    ),
    .ddc_sda    (ddc_sda    ),
    .tmds_clk_p (tmds_clk_p ),
    .tmds_clk_n (tmds_clk_n ),
    .tmds_data_p(tmds_data_p),
    .tmds_data_n(tmds_data_n)



);

endmodule

