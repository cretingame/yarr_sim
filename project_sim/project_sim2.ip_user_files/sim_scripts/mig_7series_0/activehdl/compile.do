vlib work
vlib activehdl

vlib activehdl/xil_defaultlib
vlib activehdl/xpm

vmap xil_defaultlib activehdl/xil_defaultlib
vmap xpm activehdl/xpm

vlog -work xil_defaultlib -v2k5 -sv \
"/opt/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"/opt/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_base.sv" \
"/opt/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_dpdistram.sv" \
"/opt/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_dprom.sv" \
"/opt/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_sdpram.sv" \
"/opt/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_spram.sv" \
"/opt/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_sprom.sv" \
"/opt/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_memory/hdl/xpm_memory_tdpram.sv" \

vcom -work xpm -93 \
"/opt/Xilinx/Vivado/2016.2/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work xil_defaultlib -v2k5 \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/clocking/mig_7series_v4_0_clk_ibuf.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/clocking/mig_7series_v4_0_infrastructure.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/clocking/mig_7series_v4_0_iodelay_ctrl.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/clocking/mig_7series_v4_0_tempmon.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_0_arb_mux.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_0_arb_row_col.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_0_arb_select.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_0_bank_cntrl.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_0_bank_common.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_0_bank_compare.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_0_bank_mach.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_0_bank_queue.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_0_bank_state.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_0_col_mach.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_0_mc.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_0_rank_cntrl.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_0_rank_common.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_0_rank_mach.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/controller/mig_7series_v4_0_round_robin_arb.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/ecc/mig_7series_v4_0_ecc_buf.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/ecc/mig_7series_v4_0_ecc_dec_fix.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/ecc/mig_7series_v4_0_ecc_gen.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/ecc/mig_7series_v4_0_ecc_merge_enc.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/ecc/mig_7series_v4_0_fi_xor.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/ip_top/mig_7series_v4_0_mem_intfc.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/ip_top/mig_7series_v4_0_memc_ui_top_std.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_byte_group_io.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_byte_lane.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_tempmon.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_calib_top.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_skip_calib_tap.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_if_post_fifo.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_mc_phy.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_mc_phy_wrapper.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_of_pre_fifo.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_4lanes.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ck_addr_cmd_delay.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_init.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_dqs_found_cal.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_dqs_found_cal_hr.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_oclkdelay_cal.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_prbs_rdlvl.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_rdlvl.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_wrcal.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_wrlvl.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_wrlvl_off_delay.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_prbs_gen.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_lim.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_poc_top.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_mux.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_data.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_samp.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_edge.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_cntlr.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_ocd_po_cntlr.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_poc_pd.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_poc_tap_base.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_poc_meta.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_poc_edge_store.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_poc_cc.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/ui/mig_7series_v4_0_ui_cmd.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/ui/mig_7series_v4_0_ui_rd_data.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/ui/mig_7series_v4_0_ui_top.v" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/ui/mig_7series_v4_0_ui_wr_data.v" \

vcom -work xil_defaultlib -93 \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/phy/mig_7series_v4_0_ddr_phy_top.vhd" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/mig_7series_0_mig_sim.vhd" \
"../../../../../../Yarr-fw/ip-cores/kintex7/mig_7series_0/mig_7series_0/user_design/rtl/mig_7series_0.vhd" \

vlog -work xil_defaultlib "glbl.v"

