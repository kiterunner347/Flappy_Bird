# flappy_bird
由于网络原因不知道原项目是不是完整上传，但hdmi_colorbar.srcs里面的文件应该是完整的，我猜可以正常运行。
该项目基于野火升腾Mini FPGA开发板Xilinx Artix-7 XC7A35T开发板,实现FPGA中Flappy Bird游戏，上位机通过网线传输控制信号W/A/S/D，W使小鸟跳跃，A/D为小鸟左移右移,S开始游戏。

*eth_udp_loop
 *rgmii_rx
 *udp/udp_rx
 *led
 *hdmi_colorbar
  *vga_ctrl
  *key
  *vga_pic
  *hdmi_ctrl
   *encode
   *par_to_ser
  *seg_dynamic/bcd8421
 
