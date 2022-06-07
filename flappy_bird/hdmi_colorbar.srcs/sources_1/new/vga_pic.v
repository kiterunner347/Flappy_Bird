`timescale  1ns/1ns

module  vga_pic
(
    input   wire            vga_clk     ,   //输入工作时钟,频率25MHz
    input   wire            sys_rst_n   ,   //输入复位信号,低电平有效
    input   wire    [11:0]  pix_x       ,   //输入VGA有效显示区域像素点X轴坐标
    input   wire    [11:0]  pix_y       ,   //输入VGA有效显示区域像素点Y轴坐标
    input   wire    [3 :0]  data_in     ,
    
    output  wire    [15:0]  pix_data    ,   //输出像素点色彩信息
    output  reg     [19:0]  score       
);

//********************************************************************//
//****************** Parameter and Internal Signal *******************//
//********************************************************************//
//parameter define
reg           flag_tail1  ;    //像素点是否在上方垃圾桶
reg           flag_tail2  ;    //像素点是否在下方垃圾桶
reg           flag_head1  ;    //像素点是否在上方垃圾桶头部
reg           flag_head2  ;    //像素点是否在下方垃圾桶头部
reg           flag_bird   ;    //像素点是否在小鸟
reg           flag_back   ;    //像素点是否在背景
reg           flag_over   ;    //像素点是否在结束像素
reg  [2:0]    num1        ;    //上方垃圾桶长度 
reg  [2:0]    num2        ;    //上方垃圾桶长度 
reg  [3:0]    state       ;    //小鸟向上或向下的状态
reg           finish      ;    //游戏结束状态
                          
reg  [8:0]    ps_locx     ;    //小鸟坐标x 
reg  [8:0]    ps_locy     ;    //小鸟坐标y
reg  [9:0]    bin_locx1   ;    //一号垃圾桶坐标x1
reg  [9:0]    bin_locx2   ;    //二号垃圾桶坐标x2
reg  [8:0]    gnd_locx    ;    //背景相对坐标x
reg  [8:0]    gnd_locy    ;    //背景相对坐标y
                          
reg  [9:0]    addra       ;    //bird地址
reg  [9:0]    addra_up    ;    //bird_up,小鸟上行地址
reg  [9:0]    addra_down  ;    //bird_down,小鸟下行地址
reg  [12:0]   addrb       ;    //background,背景图片地址
reg  [9:0]    addrc       ;    //tail,垃圾桶地址
reg  [8:0]    addrd       ;    //head,垃圾桶头部地址
reg  [13:0]   addre       ;    //gameover,游戏结束地址
                          
wire [15:0]   douta       ;
wire [15:0]   douta_up    ;
wire [15:0]   douta_down  ;
wire [15:0]   doutb       ;
wire [15:0]   doutc       ;
wire [15:0]   doutd       ;
wire [15:0]   doute       ;

parameter   H_VALID =   12'd640 ,   //行有效数据
            V_VALID =   12'd480 ;   //场有效数据

parameter   bird_wid       =   8'd32,   //小鸟宽度
            bird_height    =   8'd32,   //小鸟高度
            tail_wid       =   8'd32,   //垃圾桶宽度
            tail_height    =   8'd32,   //垃圾桶高度
            head_wid       =   8'd32,   //垃圾桶头部宽度
            head_height    =   8'd16,   //垃圾桶头部高度
            speed          =   8'd1 ,   //小鸟下坠速度
            blank          =   3'd6;    //跨越空隙
            

//********************************************************************//
//***************************** Main Code ****************************//
//********************************************************************//

//游戏结束判断
always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0 || data_in == 4'b0100)
        finish <= 0 ;
    else begin
        if(finish == 1'b1)
            finish <= 1'b1; //一旦出现1,就将其保存
        else
            if(ps_locy > 420)
                finish <= 1; //小鸟坠地，GG
            else
                //小鸟与垃圾桶相撞，GG
                finish <= (flag_bird && flag_tail1) || (flag_bird && flag_head1) || (flag_bird && flag_tail2) || (flag_bird && flag_head2) ;
    end

//背景绘制
always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0)begin
            gnd_locx  <= 0;  
            gnd_locy  <= 0;
            addrb <= 0;
        end
    else begin
        // 求取背景相对坐标，本代码为一行*10列
        gnd_locx <= pix_x % 64;
        gnd_locy <= pix_y % 352;
        addrb <= gnd_locy * 64 + gnd_locx;
    end


//小鸟位置
always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0  || data_in == 4'b0100)begin
        //小鸟位置与上下行状态
        ps_locx  <= 303;  
        ps_locy  <= 223;
        state    <= 0  ;
    end
    else begin
        if(finish == 1'b1) begin
            ps_locy <= ps_locy;
            ps_locx <= ps_locx;
        end
        else if(pix_x == 12'h0 && pix_y == 12'h0) begin
            // state：0-7小鸟位置y匀加速下坠，若检测到key1则跳转到8上升
            // state：8-15小鸟位置y匀减速上升；
            case(state)
                0 : begin state <= (data_in == 4'b0001)? 8:1; ps_locy  <= ps_locy + speed * 1; end
                1 : begin state <= (data_in == 4'b0001)? 8:2; ps_locy  <= ps_locy + speed * 1; end
                2 : begin state <= (data_in == 4'b0001)? 8:3; ps_locy  <= ps_locy + speed * 2; end
                3 : begin state <= (data_in == 4'b0001)? 8:4; ps_locy  <= ps_locy + speed * 2; end
                4 : begin state <= (data_in == 4'b0001)? 8:5; ps_locy  <= ps_locy + speed * 3; end
                5 : begin state <= (data_in == 4'b0001)? 8:6; ps_locy  <= ps_locy + speed * 3; end
                6 : begin state <= (data_in == 4'b0001)? 8:7; ps_locy  <= ps_locy + speed * 4; end
                7 : begin state <= (data_in == 4'b0001)? 8:7; ps_locy  <= ps_locy + speed * 4; end
                8 : begin state <= 9 ; ps_locy  <= ps_locy - 20; end
                9 : begin state <= 10; ps_locy  <= ps_locy - 16; end
                10: begin state <= 11; ps_locy  <= ps_locy - 12; end
                11: begin state <= 12; ps_locy  <= ps_locy - 8 ; end
                12: begin state <= 13; ps_locy  <= ps_locy - 6 ; end
                13: begin state <= 14; ps_locy  <= ps_locy - 4 ; end
                14: begin state <= 15; ps_locy  <= ps_locy - 2 ; end
                15: begin state <= 0 ; ps_locy  <= ps_locy - 1 ; end
            endcase
            ps_locx <= (data_in == 4'b0010)? ps_locx - 5 * speed : ((data_in == 4'b1000) ? ps_locx + 5 * speed : ps_locx);
        end
    end

//垃圾桶位置
always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0 || data_in == 4'b0100)begin
            bin_locx1  <= 576;  
            bin_locx2  <= 256;
            num1       <= 3  ;// 垃圾桶1的长度
            num2       <= 5  ;// 垃圾桶长度
            score      <= 0  ;// 当前分数
        end
    else begin
        if(finish ==1'b1) begin
            bin_locx1 <= bin_locx1;
            bin_locx2 <= bin_locx2;
        end else if(pix_x == 12'h0 && pix_y == 12'h0) 
        begin
            if(bin_locx1 > 2) begin
                bin_locx1  <= bin_locx1 - 2; //逐渐左移
                end
            else begin
                bin_locx1  <= 640-tail_wid; //挪到最右侧
                num1 <= (num1 > 6)? 2 : num1 + 1 ; //长度逐渐增加
                score <= (score>100)? 0 : score + 1; //分数加一
            end
            if(bin_locx2 > 2) begin
                bin_locx2  <= bin_locx2 - 2;
                end
            else begin
                bin_locx2  <= 640-tail_wid;
                num2 <= (num2 > 6)? 2 : num2 + 1 ;
                score <= (score>100)? 0 : score + 1;
            end
        end
    end

//图片显示
always@(posedge vga_clk or negedge sys_rst_n)
    if(sys_rst_n == 1'b0 || data_in == 4'b0100)begin     
            addra       <= 0;
            addra_up    <= 0;
            addra_down  <= 0;
            addrc       <= 0;
            addrd       <= 0;
            addre       <= 0;
            flag_tail1  <= 0;
            flag_tail2  <= 0;
            flag_head1  <= 0;
            flag_head2  <= 0;
            flag_bird   <= 0;
            flag_back   <= 0;
            flag_over   <= 0;
        end
    else begin
        //垃圾桶1判断，分为尾部和头部
        if((pix_x >= bin_locx1 && pix_x <= bin_locx1 + tail_wid - 1 && pix_y >= 0 && pix_y <= tail_height * num1 - 1) ||
           (pix_x >= bin_locx1 && pix_x <= bin_locx1 + tail_wid - 1 && pix_y >= tail_height * (num1+blank) && pix_y <= 480 - 1)) begin
            addrc    <= addrc + 1;
            flag_tail1 <= 1'b1;
        end else flag_tail1 <= 1'b0;
        
        if((pix_x >= bin_locx1 && pix_x <= bin_locx1 + tail_wid - 1 && pix_y >= tail_height * num1 && pix_y <= tail_height * num1 + head_height-1)||
           (pix_x >= bin_locx1 && pix_x <= bin_locx1 + tail_wid - 1 && pix_y >= tail_height * (num1+blank)-16 && pix_y <= tail_height * (num1+blank)-1)) begin
            addrd    <= addrd + 1;
            flag_head1 <= 1'b1;
        end else flag_head1 <= 1'b0;
        
        //垃圾桶2判断
        if((pix_x >= bin_locx2 && pix_x <= bin_locx2 + tail_wid - 1 && pix_y >= 0 && pix_y <= tail_height * num2 - 1) ||
           (pix_x >= bin_locx2 && pix_x <= bin_locx2 + tail_wid - 1 && pix_y >= tail_height * (num2+blank) && pix_y <= 480 - 1)) begin
            addrc    <= addrc + 1;
            flag_tail2 <= 1'b1;
        end else flag_tail2 <= 1'b0;
        
        if((pix_x >= bin_locx2 && pix_x <= bin_locx2 + tail_wid - 1 && pix_y >= tail_height * num2 && pix_y <= tail_height * num2 + head_height-1)||
           (pix_x >= bin_locx2 && pix_x <= bin_locx2 + tail_wid - 1 && pix_y >= tail_height * (num2+blank)-16 && pix_y <= tail_height * (num2+blank)-1)) begin
            addrd    <= addrd + 1;
            flag_head2 <= 1'b1;
        end else flag_head2 <= 1'b0;
        
        //bird判断
        if(pix_x >= ps_locx && pix_x <= ps_locx + bird_wid - 1 && pix_y >= ps_locy && pix_y <= ps_locy + bird_height - 1) begin
            addra     <= addra + 1;
            addra_up  <= addra_up + 1;
            addra_down<= addra_down + 1;
            flag_bird <= 1'b1;
        end else flag_bird <= 1'b0;
        
        //over判断
        if(pix_x >= 191 && pix_x <= 446 && pix_y >= 207 && pix_y <= 270) begin
            addre     <= addre + 1;
            flag_over <= 1'b1;
        end else flag_over <= 1'b0;
        
        //背景判断
        if(pix_y >= 352) begin
            flag_back <= 1'b1;
        end else flag_back <= 1'b0;
    end
    
assign pix_data = (finish == 1'b1 )?
                  ((flag_over  == 1'b1)? doute :                                //gameover
                  (flag_tail1  == 1'b1)? doutc :                                //tail1
                  (flag_head1  == 1'b1)? doutd :                                //head1
                  (flag_tail2  == 1'b1)? doutc :                                //tail2
                  (flag_head2  == 1'b1)? doutd :                                //head2
                  (flag_bird   == 1'b1)? ((state <=7)? douta_down : douta_up):  //bird
                  (flag_back   == 1'b1)? doutb :                                //background,16'h4e19为蓝色背景
                  16'h4e19 ) :
                  ((flag_tail1 == 1'b1)? doutc :                                //tail1
                  (flag_head1  == 1'b1)? doutd :                                //head1
                  (flag_tail2  == 1'b1)? doutc :                                //tail2
                  (flag_head2  == 1'b1)? doutd :                                //head2
                  (flag_bird   == 1'b1)? ((state <=7)? douta_down : douta_up):  //bird
                  (flag_back   == 1'b1)? doutb :                                //background
                  16'h4e19 );                                                   //blue_background

// assign pix_data = doute;

bird bird (
  .clka(vga_clk), 
  .addra(addra) ,  
  .douta(douta)   
);

bird_up bird_up (
  .clka(vga_clk)  , 
  .addra(addra_up), 
  .douta(douta_up)  
);

bird_down bird_down (
  .clka(vga_clk)    ,
  .addra(addra_down),
  .douta(douta_down) 
);

gnd_pic gnd (
  .clka(vga_clk),
  .addra(addrb) , 
  .douta(doutb)  
);

tail tail(
  .clka(vga_clk),
  .addra(addrc) , 
  .douta(doutc)  
);

head head (
  .clka(vga_clk), 
  .addra(addrd) ,  
  .douta(doutd)   
);

over over (
  .clka(vga_clk), 
  .addra(addre) ,  
  .douta(doute)   
);

endmodule
