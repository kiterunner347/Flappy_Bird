`timescale  1ns/1ns

module udp(
    input                rst_n       , //��λ�źţ��͵�ƽ��Ч
    //GMII�ӿ�
    input                gmii_rx_clk , //GMII��������ʱ��
    input                gmii_rx_dv  , //GMII����������Ч�ź�
    input        [7:0]   gmii_rxd    , //GMII��������
    //�û��ӿ�
    output               rec_pkt_done, //��̫���������ݽ�������ź�
    output               rec_en      , //��̫�����յ�����ʹ���ź�
    output       [31:0]  rec_data    , //��̫�����յ�����
    output       [15:0]  rec_byte_num  //��̫�����յ���Ч�ֽ��� ��λ:byte
    );

//parameter define
//������MAC��ַ
parameter BOARD_MAC = 48'hff_ff_ff_ff_ff_ff;   //���վ����MAC��ַ��IP��ַ�ɶ��㴫�룬����ֻ��Ҫ����ͺ�
//������IP��ַ
parameter BOARD_IP  = {8'd0,8'd0,8'd0,8'd0};
//Ŀ��MAC��ַ
parameter  DES_MAC  = 48'hff_ff_ff_ff_ff_ff;
//Ŀ��IP��ַ
parameter  DES_IP   = {8'd0,8'd0,8'd0,8'd0};

//*****************************************************
//**                    main code
//*****************************************************


//��̫������ģ��
udp_rx
   #(
    .BOARD_MAC       (BOARD_MAC),         //��������
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