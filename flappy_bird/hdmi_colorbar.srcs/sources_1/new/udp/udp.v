`timescale  1ns/1ns

module udp(
    input                rst_n       , //复位信号，低电平有效
    //GMII接口
    input                gmii_rx_clk , //GMII接收数据时钟
    input                gmii_rx_dv  , //GMII输入数据有效信号
    input        [7:0]   gmii_rxd    , //GMII输入数据
    //用户接口
    output               rec_pkt_done, //以太网单包数据接收完成信号
    output               rec_en      , //以太网接收的数据使能信号
    output       [31:0]  rec_data    , //以太网接收的数据
    output       [15:0]  rec_byte_num  //以太网接收的有效字节数 单位:byte
    );

//parameter define
//开发板MAC地址
parameter BOARD_MAC = 48'hff_ff_ff_ff_ff_ff;   //最终具体的MAC地址和IP地址由顶层传入，这里只需要定义就好
//开发板IP地址
parameter BOARD_IP  = {8'd0,8'd0,8'd0,8'd0};
//目的MAC地址
parameter  DES_MAC  = 48'hff_ff_ff_ff_ff_ff;
//目的IP地址
parameter  DES_IP   = {8'd0,8'd0,8'd0,8'd0};

//*****************************************************
//**                    main code
//*****************************************************


//以太网接收模块
udp_rx
   #(
    .BOARD_MAC       (BOARD_MAC),         //参数例化
    .BOARD_IP        (BOARD_IP )
    )
   u_udp_rx(
    .clk             (gmii_rx_clk ),
    .rst_n           (rst_n       ),
    .gmii_rx_dv      (gmii_rx_dv  ),
    .gmii_rxd        (gmii_rxd    ),
    .rec_pkt_done    (rec_pkt_done),
    .rec_en          (rec_en      ),
    .rec_data        (rec_data    ),
    .rec_byte_num    (rec_byte_num)
    );

endmodule