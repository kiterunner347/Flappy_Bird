`timescale  1ns/1ns

module eth_udp_loop(
    input                  sys_clk     , //系统时钟
    input                  sys_rst_n   , //系统复位信号，低电平有效
    //PL以太网RGMII接口                
    input                  eth_rxc     , //RGMII接收数据时钟
    input                  eth_rx_ctl  , //RGMII输入数据有效信号
    input           [3:0]  eth_rxd     , //RGMII输入数据
    
    output          [3:0]  led_out     ,
    output  wire           ddc_scl     ,
    output  wire           ddc_sda     ,
    output  wire           tmds_clk_p  ,
    output  wire           tmds_clk_n  ,   //HDMI时钟差分信号
    output  wire    [2:0]  tmds_data_p ,
    output  wire    [2:0]  tmds_data_n ,   //HDMI图像差分信号
    output  wire    [5:0]  sel         ,   //数码管位选信号
    output  wire    [7:0]  seg             //数码管段选信号
    );

//parameter define
//开发板MAC地址
parameter  BOARD_MAC = 48'h12_34_56_78_9a_bc;
//开发板IP地址
parameter  BOARD_IP  = {8'd192,8'd168,8'd0,8'd234};
//目的MAC地址
parameter  DES_MAC   = 48'hff_ff_ff_ff_ff_ff;
//目的IP地址
parameter  DES_IP    = {8'd192,8'd168,8'd0,8'd145};

//wire define
wire          clk_phase   ; //用于IO延时的时钟

wire          gmii_rx_clk; //GMII接收时钟
wire          gmii_rx_dv ; //GMII接收数据有效信号
wire  [7:0]   gmii_rxd   ; //GMII接收数据

wire          rec_pkt_done  ; //UDP单包数据接收完成信号
wire          rec_en        ; //UDP接收的数据使能信号
wire  [31:0]  rec_data      ; //UDP接收的数据
wire  [15:0]  rec_byte_num  ; //UDP接收的有效字节数 单位:byte
wire  [15:0]  tx_byte_num   ; //UDP发送的有效字节数 单位:byte
wire          udp_tx_done   ; //UDP发送完成信号
wire          tx_req        ; //UDP读数据请求信号
wire  [31:0]  tx_data       ; //UDP待发送数据
wire  [31:0]  tx_data_fifo;

reg   [31:0]  cnt;
reg           led_reg;
reg           tx_flag;

//*****************************************************
//**                    main code
//*****************************************************

// assign tx_start_en = key ? rec_pkt_done : tx_flag;
// assign tx_byte_num = key ? rec_byte_num : 4;
// assign tx_data = key ? tx_data_fifo : 32'h31323334;
assign eth_rst_n = 1'b1;
assign led = led_reg;

//MMCM/PLL
clk_wiz_1 u_clk_phase
(
    .clk_in1   (eth_rxc     ),  //以太网接收时钟
    .clk_out1  (clk_phase   ),  //经过相位偏移后的时钟
    .reset     (~sys_rst_n  ),  //pll复位
    .locked    (      )   //pll时钟稳定标识
);

wire    clk_test;

/* clk_wiz_1 u_clk
(
    .clk_in1   (sys_clk     ),  //以太网接收时钟
    .clk_out1  (clk_test    ),  //经过相位偏移后的时钟
    .reset     (~sys_rst_n  ),  //pll复位
    .locked    (      )   //pll时钟稳定标识
); */


always @(posedge clk_phase)begin
    if(cnt == 32'd30_000_000)
        cnt <= 32'd0;
    else
        cnt <= cnt + 1'b1;
end

always @(posedge clk_phase)begin
    if(cnt == 32'd30_000_000)
        led_reg <= ~led_reg;
    else
        led_reg <= led_reg;
end

always @(posedge clk_phase)begin
    if(cnt == 32'd30_000_000)
        tx_flag <= 1'b1;
    else
        tx_flag <= 1'b0;
end

//RGMII接收
rgmii_rx u_rgmii_rx(
    .rgmii_rxc     (clk_phase   ),
    .rgmii_rx_ctl  (eth_rx_ctl  ),
    .rgmii_rxd     (eth_rxd     ),
    
    .gmii_rx_clk   (gmii_rx_clk ),
    .gmii_rx_dv    (gmii_rx_dv  ),
    .gmii_rxd      (gmii_rxd    )
    );

//UDP通信
udp
   #(
    .BOARD_MAC     (BOARD_MAC),      //参数例化
    .BOARD_IP      (BOARD_IP ),
    .DES_MAC       (DES_MAC  ),
    .DES_IP        (DES_IP   )
    )
   u_udp(
    .rst_n         (sys_rst_n   ),

    .gmii_rx_clk   (gmii_rx_clk ),//gmii接收
    .gmii_rx_dv    (gmii_rx_dv  ),
    .gmii_rxd      (gmii_rxd    ),

    .rec_pkt_done  (rec_pkt_done),  //数据包接收结束
    .rec_en        (rec_en      ),  //四字节接收使能
    .rec_data      (rec_data    ),  //接收数据
    .rec_byte_num  (rec_byte_num)   //接收到的有效数据长度
    );
    
led led_inst
(   
    .clk          (sys_clk   ),
    .rst_n        (sys_rst_n ),
    .data_in      (rec_data  ),  //input     key_in

    .led_out      (led_out   )   //output    led_out
);

hdmi_colorbar hdmi_colorbar_inst
(
    .sys_clk     (sys_clk    ),   //输入工作时钟,频率50MHz
    .sys_rst_n   (sys_rst_n  ),   //输入复位信号,低电平有效
    .data_in     (rec_data   ),   //输入按键
  
    .ddc_scl     (ddc_scl    ),
    .ddc_sda     (ddc_sda    ),
    .tmds_clk_p  (tmds_clk_p ),
    .tmds_clk_n  (tmds_clk_n ),   //HDMI时钟差分信号
    .tmds_data_p (tmds_data_p),
    .tmds_data_n (tmds_data_n),   //HDMI图像差分信号
    .sel         (sel        ),   //数码管位选信号
    .seg         (seg        )    //数码管段选信号

);

endmodule


