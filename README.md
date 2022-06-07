# flappy_bird
由于网络原因不知道原项目是不是完整上传，但hdmi_colorbar.srcs里面的文件应该是完整的，我猜可以正常运行。

该项目基于野火升腾Mini FPGA的Xilinx Artix-7 XC7A35T开发板,实现FPGA中Flappy Bird游戏，参考野火教程中的实例代码改编而来，上位机通过网线传输控制信号W/A/S/D，W使小鸟跳跃，A/D为小鸟左移右移,S开始游戏。

flappy_bird\hdmi_colorbar.srcs\sources_1\new文件为verilog语言编写的主要程序文件，具体结构如下所示
* eth_udp_loop : 项目顶层文件
  * rgmii_rx ：将RGMII数据信号转换为GMII数据信号
  * udp/udp_rx：采用状态机的方式读取MAC数据包、IP数据包、UDP数据包
  * led：当按下W/A/S/D时，对应的LED1-4亮起
  * hdmi_colorbar：HDMI图像显示输出
    * vga_ctrl：按照VGA时序生成场同步、行同步信息、pix_x、pix_y等信息
    * key：可以靠按键输入控制信息
    * vga_pic：主要的Flappy_Bird游戏逻辑实现模块
    * hdmi_ctrl：HDMI信号控制
      * encode：编码，将8bit RGB各通道数据编码为10bit信息
      * par_to_ser：10bit并行信号转换为1bit串行信号，并且改为TMDS差分信号
    * seg_dynamic/bcd8421：显示当前Flappy_Bird的游戏得分
 
项目中涉及到ROM存储基本的图像元素构建游戏画面，pic文件夹为flappy_bird基本图像元素，最后可实现效果如图所示：
![图像](https://github.com/kiterunner347/flappy_bird/blob/main/pic/%E7%A4%BA%E6%84%8F%E5%9B%BE.png)

演示视频连接()
