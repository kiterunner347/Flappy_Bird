-makelib ies_lib/xpm -sv \
  "D:/Software/Xilinx/Vivado/2021.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "D:/Software/Xilinx/Vivado/2021.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib ies_lib/xpm \
  "D:/Software/Xilinx/Vivado/2021.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../ip/clk_wiz_1/clk_wiz_1_clk_wiz.v" \
  "../../../ip/clk_wiz_1/clk_wiz_1.v" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

