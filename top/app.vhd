----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/18/2016 01:10:56 PM
-- Design Name: 
-- Module Name: app - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity app is
    Generic(
        AXI_BUS_WIDTH : integer := 64;
        axis_data_width_c : integer := 64;
        axis_rx_tkeep_width_c : integer := 64/8;
        axis_rx_tuser_width_c : integer := 22;
        wb_address_width_c : integer := 8;
        wb_data_width_c : integer := 32;
        address_mask_c : STD_LOGIC_VECTOR(32-1 downto 0) := X"000000FF"
        );
    Port ( clk_i : in STD_LOGIC;
           rst_i : in STD_LOGIC;
           user_lnk_up_i : in STD_LOGIC;
           user_app_rdy_i : in STD_LOGIC;
           
           -- AXI-Stream bus
           m_axis_tx_tready_i : in STD_LOGIC;
           m_axis_tx_tdata_o : out STD_LOGIC_VECTOR(AXI_BUS_WIDTH-1 DOWNTO 0);
           m_axis_tx_tkeep_o : out STD_LOGIC_VECTOR(AXI_BUS_WIDTH/8-1 DOWNTO 0);
           m_axis_tx_tlast_o : out STD_LOGIC;
           m_axis_tx_tvalid_o : out STD_LOGIC;
           m_axis_tx_tuser_o : out STD_LOGIC_VECTOR(3 DOWNTO 0);
           s_axis_rx_tdata_i : in STD_LOGIC_VECTOR(AXI_BUS_WIDTH-1 DOWNTO 0);
           s_axis_rx_tkeep_i : in STD_LOGIC_VECTOR(AXI_BUS_WIDTH/8-1 DOWNTO 0);
           s_axis_rx_tlast_i : in STD_LOGIC;
           s_axis_rx_tvalid_i : in STD_LOGIC;
           s_axis_rx_tready_o : out STD_LOGIC;
           s_axis_rx_tuser_i : in STD_LOGIC_VECTOR(21 DOWNTO 0);
           
           -- PCIe interrupt config
           cfg_interrupt_o : out STD_LOGIC;
           cfg_interrupt_rdy_i : in STD_LOGIC;
           cfg_interrupt_assert_o : out STD_LOGIC;
           cfg_interrupt_di_o : out STD_LOGIC_VECTOR(7 DOWNTO 0);
           cfg_interrupt_do_i : in STD_LOGIC_VECTOR(7 DOWNTO 0);
           cfg_interrupt_mmenable_i : in STD_LOGIC_VECTOR(2 DOWNTO 0);
           cfg_interrupt_msienable_i : in STD_LOGIC;
           cfg_interrupt_msixenable_i : in STD_LOGIC;
           cfg_interrupt_msixfm_i : in STD_LOGIC;
           cfg_interrupt_stat_o : out STD_LOGIC;
           cfg_pciecap_interrupt_msgnum_o : out STD_LOGIC_VECTOR(4 DOWNTO 0);
           
           --I/O
           usr_sw_i : in STD_LOGIC_VECTOR (2 downto 0);
           usr_led_o : out STD_LOGIC_VECTOR (3 downto 0);
           front_led_o : out STD_LOGIC_VECTOR (3 downto 0)
           );
end app;

architecture Behavioral of app is

    component simple_counter is
        Port ( 
               rst_i : in STD_LOGIC;
               clk_i : in STD_LOGIC;
               count_o : out STD_LOGIC_VECTOR (28 downto 0)
                );
    end component;
    
	Component wb_master64 is
		Generic (
			axis_data_width_c : integer := 64;
			wb_address_width_c : integer := 64;
			wb_data_width_c : integer := 32;
			address_mask_c : STD_LOGIC_VECTOR(64-1 downto 0) := X"00000000" & X"000000FF" -- depends on pcie memory size
		);
		Port (
			clk_i : in STD_LOGIC;
			rst_i : in STD_LOGIC;
			-- Slave AXI-Stream
			s_axis_rx_tdata_i : in STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
			s_axis_rx_tkeep_i : in STD_LOGIC_VECTOR (axis_data_width_c/8 - 1 downto 0);
			s_axis_rx_tuser_i : in STD_LOGIC_VECTOR (21 downto 0);
			s_axis_rx_tlast_i : in STD_LOGIC;
			s_axis_rx_tvalid_i : in STD_LOGIC;
			s_axis_rx_tready_o : out STD_LOGIC;
			-- Master AXI-Stream
			wbm_arb_tdata_o : out STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
			wbm_arb_tkeep_o : out STD_LOGIC_VECTOR (axis_data_width_c/8 - 1 downto 0);
			wbm_arb_tuser_o : out STD_LOGIC_VECTOR (3 downto 0);
			wbm_arb_tlast_o : out STD_LOGIC;
			wbm_arb_tvalid_o : out STD_LOGIC;
			wbm_arb_tready_i : in STD_LOGIC;
			wbm_arb_req_o    : out  std_logic;
			-- L2P DMA
			pd_pdm_data_valid_o  : out std_logic;                      -- Indicates Data is valid
			pd_pdm_data_last_o   : out std_logic;                      -- Indicates end of the packet
			pd_pdm_data_o        : out std_logic_vector(63 downto 0);  -- Data
			-- Wishbone master
			wb_adr_o : out STD_LOGIC_VECTOR (64 - 1 downto 0);
			wb_dat_o : out STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
			wb_dat_i : in STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
			wb_cyc_o : out STD_LOGIC;
			--wb_sel_o : out STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
			wb_stb_o : out STD_LOGIC;
			wb_we_o : out STD_LOGIC;
			wb_ack_i : in STD_LOGIC
		);
	end component;
 
	component dma_controller is
	  port
		(
		  ---------------------------------------------------------
		  -- GN4124 core clock and reset
		  clk_i   : in std_logic;
		  rst_n_i : in std_logic;

		  ---------------------------------------------------------
		  -- Interrupt request
		  dma_ctrl_irq_o : out std_logic_vector(1 downto 0);

		  ---------------------------------------------------------
		  -- To the L2P DMA master and P2L DMA master
		  dma_ctrl_carrier_addr_o : out std_logic_vector(31 downto 0);
		  dma_ctrl_host_addr_h_o  : out std_logic_vector(31 downto 0);
		  dma_ctrl_host_addr_l_o  : out std_logic_vector(31 downto 0);
		  dma_ctrl_len_o          : out std_logic_vector(31 downto 0);
		  dma_ctrl_start_l2p_o    : out std_logic;  -- To the L2P DMA master
		  dma_ctrl_start_p2l_o    : out std_logic;  -- To the P2L DMA master
		  dma_ctrl_start_next_o   : out std_logic;  -- To the P2L DMA master
		  dma_ctrl_byte_swap_o    : out std_logic_vector(1 downto 0);
		  dma_ctrl_abort_o        : out std_logic;
		  dma_ctrl_done_i         : in  std_logic;
		  dma_ctrl_error_i        : in  std_logic;

		  ---------------------------------------------------------
		  -- From P2L DMA master
		  next_item_carrier_addr_i : in std_logic_vector(31 downto 0);
		  next_item_host_addr_h_i  : in std_logic_vector(31 downto 0);
		  next_item_host_addr_l_i  : in std_logic_vector(31 downto 0);
		  next_item_len_i          : in std_logic_vector(31 downto 0);
		  next_item_next_l_i       : in std_logic_vector(31 downto 0);
		  next_item_next_h_i       : in std_logic_vector(31 downto 0);
		  next_item_attrib_i       : in std_logic_vector(31 downto 0);
		  next_item_valid_i        : in std_logic;

		  ---------------------------------------------------------
		  -- Wishbone slave interface
		  wb_clk_i : in  std_logic;                      -- Bus clock
		  wb_adr_i : in  std_logic_vector(3 downto 0);   -- Adress
		  wb_dat_o : out std_logic_vector(31 downto 0);  -- Data in
		  wb_dat_i : in  std_logic_vector(31 downto 0);  -- Data out
		  wb_sel_i : in  std_logic_vector(3 downto 0);   -- Byte select
		  wb_cyc_i : in  std_logic;                      -- Read or write cycle
		  wb_stb_i : in  std_logic;                      -- Read or write strobe
		  wb_we_i  : in  std_logic;                      -- Write
		  wb_ack_o : out std_logic                       -- Acknowledge
		  );
	end component;
 
    component bram_wbs is
    generic (
        constant ADDR_WIDTH : integer := 16;
        constant DATA_WIDTH : integer := 64 
    );
    port (
        -- SYS CON
        clk            : in std_logic;
        rst            : in std_logic;
        
        -- Wishbone Slave in
        wb_adr_i            : in std_logic_vector(wb_address_width_c-1 downto 0);
        wb_dat_i            : in std_logic_vector(64-1 downto 0);
        wb_we_i            : in std_logic;
        wb_stb_i            : in std_logic;
        wb_cyc_i            : in std_logic; 
        wb_lock_i        : in std_logic; -- nyi
        
        -- Wishbone Slave out
        wb_dat_o            : out std_logic_vector(64-1 downto 0);
        wb_ack_o            : out std_logic        
    );
    end component;
	
	component l2p_arbiter is
	  generic(
		axis_data_width_c : integer := 64
	  );
	  port
		(
		  ---------------------------------------------------------
		  -- GN4124 core clock and reset
		  clk_i   : in std_logic;
		  rst_n_i : in std_logic;

		  ---------------------------------------------------------
		  -- From Wishbone master (wbm) to arbiter (arb)      
		  wbm_arb_tdata_i : in std_logic_vector (axis_data_width_c - 1 downto 0);
		  wbm_arb_tkeep_i : in std_logic_vector (axis_data_width_c/8 - 1 downto 0);
		  wbm_arb_tlast_i : in std_logic;
		  wbm_arb_tvalid_i : in std_logic;
		  wbm_arb_tready_o : out std_logic;
		  wbm_arb_req_i    : in  std_logic;
		  arb_wbm_gnt_o : out std_logic;

		  ---------------------------------------------------------
		  -- From P2L DMA master (pdm) to arbiter (arb)
		  pdm_arb_tdata_i : in std_logic_vector (axis_data_width_c - 1 downto 0);
		  pdm_arb_tkeep_i : in std_logic_vector (axis_data_width_c/8 - 1 downto 0);
		  pdm_arb_tlast_i : in std_logic;
		  pdm_arb_tvalid_i : in std_logic;
		  pdm_arb_tready_o : out std_logic;
		  pdm_arb_req_i    : in  std_logic;
		  arb_pdm_gnt_o : out std_logic;

		  ---------------------------------------------------------
		  -- From L2P DMA master (ldm) to arbiter (arb)
		  ldm_arb_tdata_i : in std_logic_vector (axis_data_width_c - 1 downto 0);
		  ldm_arb_tkeep_i : in std_logic_vector (axis_data_width_c/8 - 1 downto 0);
		  ldm_arb_tlast_i : in std_logic;
		  ldm_arb_tvalid_i : in std_logic;
		  ldm_arb_tready_o : out std_logic;
		  ldm_arb_req_i    : in  std_logic;
		  arb_ldm_gnt_o : out std_logic;

		  ---------------------------------------------------------
		  -- From arbiter (arb) to pcie_tx (tx)
		  axis_tx_tdata_o : out STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
		  axis_tx_tkeep_o : out STD_LOGIC_VECTOR (axis_data_width_c/8 - 1 downto 0);
		  axis_tx_tuser_o : out STD_LOGIC_VECTOR (3 downto 0);
		  axis_tx_tlast_o : out STD_LOGIC;
		  axis_tx_tvalid_o : out STD_LOGIC;
		  axis_tx_tready_i : in STD_LOGIC;
		  
		  ---------------------------------------------------------
		  -- Debug
		  eop_do : out std_logic
		  );
	end component;
    
	component p2l_dma_master is
	  generic (
		-- Enable byte swap module (if false, no swap)
		g_BYTE_SWAP : boolean := false
		);
	  port
		(
		  ---------------------------------------------------------
		  -- GN4124 core clock and reset
		  clk_i   : in std_logic;
		  rst_n_i : in std_logic;

		  ---------------------------------------------------------
		  -- From the DMA controller
		  dma_ctrl_carrier_addr_i : in  std_logic_vector(31 downto 0);
		  dma_ctrl_host_addr_h_i  : in  std_logic_vector(31 downto 0);
		  dma_ctrl_host_addr_l_i  : in  std_logic_vector(31 downto 0);
		  dma_ctrl_len_i          : in  std_logic_vector(31 downto 0);
		  dma_ctrl_start_p2l_i    : in  std_logic;
		  dma_ctrl_start_next_i   : in  std_logic;
		  dma_ctrl_done_o         : out std_logic;
		  dma_ctrl_error_o        : out std_logic;
		  dma_ctrl_byte_swap_i    : in  std_logic_vector(2 downto 0);
		  dma_ctrl_abort_i        : in  std_logic;

		  ---------------------------------------------------------
		  -- From P2L Decoder (receive the read completion)
		  --
		  -- Header
		  --pd_pdm_hdr_start_i   : in std_logic;                      -- Header strobe
		  --pd_pdm_hdr_length_i  : in std_logic_vector(9 downto 0);   -- Packet length in 32-bit words multiples
		  --pd_pdm_hdr_cid_i     : in std_logic_vector(1 downto 0);   -- Completion ID
		  pd_pdm_master_cpld_i : in std_logic;                      -- Master read completion with data
		  pd_pdm_master_cpln_i : in std_logic;                      -- Master read completion without data
		  --
		  -- Data
		  pd_pdm_data_valid_i  : in std_logic;                      -- Indicates Data is valid
		  pd_pdm_data_last_i   : in std_logic;                      -- Indicates end of the packet
		  pd_pdm_data_i        : in std_logic_vector(63 downto 0);  -- Data
		  pd_pdm_be_i          : in std_logic_vector(7 downto 0);   -- Byte Enable for data

		  ---------------------------------------------------------
		  -- P2L control
		  p2l_rdy_o  : out std_logic;       -- De-asserted to pause transfer already in progress
		  rx_error_o : out std_logic;       -- Asserted when transfer is aborted

		  ---------------------------------------------------------
		  -- To the P2L Interface (send the DMA Master Read request)
		  pdm_arb_tvalid_o  : out std_logic;  -- Read completion signals
		  pdm_arb_tlast_o : out std_logic;  -- Toward the arbiter
		  pdm_arb_tdata_o   : out std_logic_vector(63 downto 0);
		  pdm_arb_req_o    : out std_logic;
		  arb_pdm_gnt_i    : in  std_logic;

		  ---------------------------------------------------------
		  -- DMA Interface (Pipelined Wishbone)
		  p2l_dma_clk_i   : in  std_logic;                      -- Bus clock
		  p2l_dma_adr_o   : out std_logic_vector(31 downto 0);  -- Adress
		  p2l_dma_dat_i   : in  std_logic_vector(63 downto 0);  -- Data in
		  p2l_dma_dat_o   : out std_logic_vector(63 downto 0);  -- Data out
		  p2l_dma_sel_o   : out std_logic_vector(7 downto 0);   -- Byte select
		  p2l_dma_cyc_o   : out std_logic;                      -- Read or write cycle
		  p2l_dma_stb_o   : out std_logic;                      -- Read or write strobe
		  p2l_dma_we_o    : out std_logic;                      -- Write
		  p2l_dma_ack_i   : in  std_logic;                      -- Acknowledge
		  p2l_dma_stall_i : in  std_logic;                      -- for pipelined Wishbone
		  l2p_dma_cyc_i   : in  std_logic;                      -- L2P dma wb cycle (for bus arbitration)

		  ---------------------------------------------------------
		  -- To the DMA controller
		  next_item_carrier_addr_o : out std_logic_vector(31 downto 0);
		  next_item_host_addr_h_o  : out std_logic_vector(31 downto 0);
		  next_item_host_addr_l_o  : out std_logic_vector(31 downto 0);
		  next_item_len_o          : out std_logic_vector(31 downto 0);
		  next_item_next_l_o       : out std_logic_vector(31 downto 0);
		  next_item_next_h_o       : out std_logic_vector(31 downto 0);
		  next_item_attrib_o       : out std_logic_vector(31 downto 0);
		  next_item_valid_o        : out std_logic
		  );
	end component;
	
	component l2p_dma_master is
		generic (
			g_BYTE_SWAP : boolean := false;
			axis_data_width_c : integer := 64;
			wb_address_width_c : integer := 64;
			wb_data_width_c : integer := 64
		);
		port (
			-- GN4124 core clk and reset
			clk_i   : in std_logic;
			rst_n_i : in std_logic;

			-- From the DMA controller
			dma_ctrl_target_addr_i : in  std_logic_vector(32-1 downto 0);
			dma_ctrl_host_addr_h_i : in  std_logic_vector(32-1 downto 0);
			dma_ctrl_host_addr_l_i : in  std_logic_vector(32-1 downto 0);
			dma_ctrl_len_i         : in  std_logic_vector(32-1 downto 0);
			dma_ctrl_start_l2p_i   : in  std_logic;
			dma_ctrl_done_o        : out std_logic;
			dma_ctrl_error_o       : out std_logic;
			dma_ctrl_byte_swap_i   : in  std_logic_vector(2 downto 0);
			dma_ctrl_abort_i       : in  std_logic;

			-- To the arbiter (L2P data)
			ldm_arb_tvalid_o  : out std_logic;
			--ldm_arb_dframe_o : out std_logic;
			ldm_arb_tlast_o   : out std_logic;
			ldm_arb_tdata_o   : out std_logic_vector(axis_data_width_c-1 downto 0);
			ldm_arb_tkeep_o   : out std_logic_vector(axis_data_width_c/8-1 downto 0);
			ldm_arb_tready_i : in  std_logic;
			ldm_arb_req_o    : out std_logic;
			arb_ldm_gnt_i    : in  std_logic;


			-- L2P channel control
			l2p_edb_o  : out std_logic;                    -- Asserted when transfer is aborted
			l2p_rdy_i  : in  std_logic;                    -- De-asserted to pause transdert already in progress
			l2p_64b_address_i : in std_logic;
			tx_error_i : in  std_logic;                    -- Asserted when unexpected or malformed paket received

			-- DMA Interface (Pipelined Wishbone)
			l2p_dma_clk_i   : in  std_logic;
			l2p_dma_adr_o   : out std_logic_vector(wb_address_width_c-1 downto 0);
			l2p_dma_dat_i   : in  std_logic_vector(wb_data_width_c-1 downto 0);
			l2p_dma_dat_o   : out std_logic_vector(wb_data_width_c-1 downto 0);
			l2p_dma_sel_o   : out std_logic_vector(3 downto 0);
			l2p_dma_cyc_o   : out std_logic;
			l2p_dma_stb_o   : out std_logic;
			l2p_dma_we_o    : out std_logic;
			l2p_dma_ack_i   : in  std_logic;
			l2p_dma_stall_i : in  std_logic;
			p2l_dma_cyc_i   : in  std_logic -- P2L dma WB cycle for bus arbitration
		);
	end component;
	

    
    signal rst_n_s : std_logic;
    signal count_s : STD_LOGIC_VECTOR (28 downto 0);
    signal eop_s : std_logic; -- Arbiter end of operation
    
	---------------------------------------------------------
    -- CSR Wishbone bus
    signal wb_adr_s : STD_LOGIC_VECTOR (64 - 1 downto 0);
    signal wb_dat_o_s : STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
    signal wb_dat_i_s : STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
    signal wb_cyc_s : STD_LOGIC;
    signal wb_sel_s : STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
    signal wb_stb_s : STD_LOGIC;
    signal wb_we_s : STD_LOGIC;
    signal wb_ack_s : STD_LOGIC;
    
	---------------------------------------------------------
    -- Slave AXI-Stream from arbiter to pcie_tx
    signal s_axis_rx_tdata_s : STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
    signal s_axis_rx_tkeep_s : STD_LOGIC_VECTOR (axis_data_width_c/8 - 1 downto 0);
    signal s_axis_rx_tuser_s : STD_LOGIC_VECTOR (21 downto 0);
    signal s_axis_rx_tlast_s : STD_LOGIC;
    signal s_axis_rx_tvalid_s :STD_LOGIC;
    signal s_axis_rx_tready_s : STD_LOGIC;
    
	---------------------------------------------------------
	-- Master AXI-Stream pcie_rx to wishbone master
    signal m_axis_tx_tdata_s : STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
    signal m_axis_tx_tkeep_s : STD_LOGIC_VECTOR (axis_data_width_c/8 - 1 downto 0);
    signal m_axis_tx_tuser_s : STD_LOGIC_VECTOR (3 downto 0);
    signal m_axis_tx_tlast_s : STD_LOGIC;
    signal m_axis_tx_tvalid_s : STD_LOGIC;
    signal m_axis_tx_tready_s : STD_LOGIC;
    
	---------------------------------------------------------
	-- From Wishbone master (wbm) to L2P DMA
	signal pd_pdm_data_valid_s : STD_LOGIC;
	signal pd_pdm_data_last_s : STD_LOGIC;
	signal pd_pdm_data_s : STD_LOGIC_VECTOR(axis_data_width_c - 1 downto 0);
	
    ---------------------------------------------------------
    -- From Wishbone master (wbm) to arbiter (arb)      
    signal wbm_arb_tdata_s : std_logic_vector (axis_data_width_c - 1 downto 0);
    signal wbm_arb_tkeep_s : std_logic_vector (axis_data_width_c/8 - 1 downto 0);
    signal wbm_arb_tlast_s : std_logic;
    signal wbm_arb_tvalid_s : std_logic;
    signal wbm_arb_req_s    : std_logic;
    signal wbm_arb_tready_s : std_logic;
	
	---------------------------------------------------------
	-- To the L2P DMA master and P2L DMA master
	signal dma_ctrl_carrier_addr_s : std_logic_vector(31 downto 0);
	signal dma_ctrl_host_addr_h_s  : std_logic_vector(31 downto 0);
	signal dma_ctrl_host_addr_l_s  : std_logic_vector(31 downto 0);
	signal dma_ctrl_len_s          : std_logic_vector(31 downto 0);
	signal dma_ctrl_start_l2p_s    : std_logic;  -- To the L2P DMA master
	signal dma_ctrl_start_p2l_s    : std_logic;  -- To the P2L DMA master
	signal dma_ctrl_start_next_s   : std_logic;  -- To the P2L DMA master
	signal dma_ctrl_byte_swap_s    : std_logic_vector(1 downto 0);
	signal dma_ctrl_abort_s        : std_logic;
	signal dma_ctrl_done_s         : std_logic;
	signal dma_ctrl_error_s        : std_logic;

	---------------------------------------------------------
	-- From P2L DMA master
	signal next_item_carrier_addr_s : std_logic_vector(31 downto 0);
	signal next_item_host_addr_h_s  : std_logic_vector(31 downto 0);
	signal next_item_host_addr_l_s  : std_logic_vector(31 downto 0);
	signal next_item_len_s          : std_logic_vector(31 downto 0);
	signal next_item_next_l_s       : std_logic_vector(31 downto 0);
	signal next_item_next_h_s       : std_logic_vector(31 downto 0);
	signal next_item_attrib_s       : std_logic_vector(31 downto 0);
	signal next_item_valid_s        : std_logic;
	
	---------------------------------------------------------
	-- To the P2L Interface (send the DMA Master Read request)
	signal pdm_arb_tvalid_s  : std_logic;  -- Read completion signals
	signal pdm_arb_tlast_s : std_logic;  -- Toward the arbiter
	signal pdm_arb_tdata_s   : std_logic_vector(63 downto 0);
	signal pdm_arb_req_s    : std_logic;
	signal pdm_arb_tready_s    : std_logic;
	
	---------------------------------------------------------
	-- DMA Interface (Pipelined Wishbone)
	signal p2l_dma_adr_s   :  std_logic_vector(31 downto 0);  -- Adress
	signal p2l_dma_dat_s2m_s   :  std_logic_vector(63 downto 0);  -- Data in
	signal p2l_dma_dat_m2s_s   :  std_logic_vector(63 downto 0);  -- Data out
	signal p2l_dma_sel_s   :  std_logic_vector(7 downto 0);   -- Byte select
	signal p2l_dma_cyc_s   :  std_logic;                      -- Read or write cycle
	signal p2l_dma_stb_s   :  std_logic;                      -- Read or write strobe
	signal p2l_dma_we_s    :  std_logic;                      -- Write
	signal p2l_dma_ack_s   :  std_logic;                      -- Acknowledge
	signal p2l_dma_stall_s :  std_logic;                      -- for pipelined Wishbone
	--signal l2p_dma_cyc_s   :  std_logic;                      -- L2P dma wb cycle (for bus arbitration)
	signal l2p_dma_adr_s   :  std_logic_vector(64-1 downto 0);
	signal l2p_dma_dat_s2m_s   :  std_logic_vector(64-1 downto 0);
	signal l2p_dma_dat_m2s_s   :  std_logic_vector(64-1 downto 0);
	signal l2p_dma_sel_s   :  std_logic_vector(3 downto 0);
	signal l2p_dma_cyc_s   :  std_logic;
	signal l2p_dma_stb_s   :  std_logic;
	signal l2p_dma_we_s    :  std_logic;
	signal l2p_dma_ack_s   :  std_logic;
	signal l2p_dma_stall_s :  std_logic;
	
	---------------------------------------------------------
	-- From L2P DMA master (ldm) to arbiter (arb)
	signal ldm_arb_tdata_s : std_logic_vector (axis_data_width_c - 1 downto 0);
	signal ldm_arb_tkeep_s : std_logic_vector (axis_data_width_c/8 - 1 downto 0);
	signal ldm_arb_tlast_s : std_logic;
	signal ldm_arb_tvalid_s : std_logic;
	signal ldm_arb_tready_s : std_logic;
	signal ldm_arb_req_s    : std_logic;
	--signal arb_ldm_gnt_s : std_logic;

begin
    
    rst_n_s <= not rst_i;
    
    cfg_interrupt_o <= '0';
    cfg_interrupt_assert_o <= '0';
    cfg_interrupt_di_o <= (others => '0');
    cfg_interrupt_stat_o <= '0';
    cfg_pciecap_interrupt_msgnum_o <= (others => '0');
    
    s_axis_rx_tdata_s <= s_axis_rx_tdata_i;
    s_axis_rx_tkeep_s <= s_axis_rx_tkeep_i;
    s_axis_rx_tlast_s <= s_axis_rx_tlast_i;
    s_axis_rx_tready_o <= s_axis_rx_tready_s;
    s_axis_rx_tuser_s <= s_axis_rx_tuser_i;
    s_axis_rx_tvalid_s <= s_axis_rx_tvalid_i;
    -- Master AXI-Stream
    m_axis_tx_tdata_o <= m_axis_tx_tdata_s;
    m_axis_tx_tkeep_o <= m_axis_tx_tkeep_s;
    m_axis_tx_tuser_o <= m_axis_tx_tuser_s;
    m_axis_tx_tlast_o <= m_axis_tx_tlast_s;
    m_axis_tx_tvalid_o <= m_axis_tx_tvalid_s;
    m_axis_tx_tready_s <= m_axis_tx_tready_i;

    cnt:simple_counter
    port map(
        rst_i => rst_i,
        clk_i => clk_i,
        count_o =>  count_s
    );
    
    wb_master:wb_master64
	port map(
		clk_i => clk_i,
		rst_i => rst_i,
		-- Slave AXI-Stream
		s_axis_rx_tdata_i => s_axis_rx_tdata_s,
		s_axis_rx_tkeep_i => s_axis_rx_tkeep_s,
		s_axis_rx_tlast_i => s_axis_rx_tlast_s,
		s_axis_rx_tready_o => s_axis_rx_tready_s,
		s_axis_rx_tuser_i => s_axis_rx_tuser_s,
		s_axis_rx_tvalid_i => s_axis_rx_tvalid_s,
		-- Master AXI-Stream
		wbm_arb_tdata_o => wbm_arb_tdata_s,
		wbm_arb_tkeep_o => wbm_arb_tkeep_s,
		wbm_arb_tuser_o => open,
		wbm_arb_tlast_o => wbm_arb_tlast_s,
		wbm_arb_tvalid_o => wbm_arb_tvalid_s,
		wbm_arb_tready_i => wbm_arb_tready_s,
		wbm_arb_req_o => wbm_arb_req_s,
		-- L2P DMA
		pd_pdm_data_valid_o => pd_pdm_data_valid_s,
        pd_pdm_data_last_o => pd_pdm_data_last_s,
        pd_pdm_data_o => pd_pdm_data_s,
		-- Wishbone Master
		wb_adr_o => wb_adr_s,
		wb_dat_o => wb_dat_o_s,
		wb_dat_i => wb_dat_i_s,
		wb_cyc_o => wb_cyc_s,
		--wb_sel_o => wb_sel_s,
		wb_stb_o => wb_stb_s,
		wb_we_o => wb_we_s,
		wb_ack_i => wb_ack_s
	);
    
	
	dma_ctrl:dma_controller
	  port map
		(
		  ---------------------------------------------------------
		  -- GN4124 core clock and reset
		  clk_i   => clk_i,
		  rst_n_i => not rst_i,

		  ---------------------------------------------------------
		  -- Interrupt request
		  dma_ctrl_irq_o => open,

		  ---------------------------------------------------------
		  -- To the L2P DMA master and P2L DMA master
		  dma_ctrl_carrier_addr_o => dma_ctrl_carrier_addr_s,
		  dma_ctrl_host_addr_h_o  => dma_ctrl_host_addr_h_s,
		  dma_ctrl_host_addr_l_o  => dma_ctrl_host_addr_l_s,
		  dma_ctrl_len_o          => dma_ctrl_len_s,
		  dma_ctrl_start_l2p_o    => dma_ctrl_start_l2p_s, -- To the L2P DMA master
		  dma_ctrl_start_p2l_o    => dma_ctrl_start_p2l_s, -- To the P2L DMA master
		  dma_ctrl_start_next_o   => dma_ctrl_start_next_s, -- To the P2L DMA master
		  dma_ctrl_byte_swap_o    => dma_ctrl_byte_swap_s,
		  dma_ctrl_abort_o        => dma_ctrl_abort_s,
		  dma_ctrl_done_i         => dma_ctrl_done_s,
		  dma_ctrl_error_i        => dma_ctrl_error_s,

		  ---------------------------------------------------------
		  -- From P2L DMA master
		  next_item_carrier_addr_i => next_item_carrier_addr_s,
		  next_item_host_addr_h_i  => next_item_host_addr_h_s,
		  next_item_host_addr_l_i  => next_item_host_addr_l_s,
		  next_item_len_i          => next_item_len_s,
		  next_item_next_l_i       => next_item_next_l_s,
		  next_item_next_h_i       => next_item_next_h_s,
		  next_item_attrib_i       => next_item_attrib_s,
		  next_item_valid_i        => next_item_valid_s,

		  ---------------------------------------------------------
		  -- Wishbone slave interface
		  wb_clk_i => clk_i,                     -- Bus clock
		  wb_adr_i => wb_adr_s(3 downto 0),   -- Adress
		  wb_dat_o => wb_dat_i_s,  -- Data in
		  wb_dat_i => wb_dat_o_s,  -- Data out
		  wb_sel_i => "1111",   -- Byte select
		  wb_cyc_i => wb_cyc_s,                      -- Read or write cycle
		  wb_stb_i => wb_stb_s,                      -- Read or write strobe
		  wb_we_i  => wb_we_s,                      -- Write
		  wb_ack_o => wb_ack_s                       -- Acknowledge
		  );

	
    
	-- ram_csr:bram_wbs
	-- generic map (
		-- ADDR_WIDTH => wb_address_width_c,
		-- DATA_WIDTH => wb_data_width_c 
	-- )
	-- port map (
		-- -- SYS CON
		-- clk            => clk_i,
		-- rst            => rst_i,
		
		-- -- Wishbone Slave in
		-- wb_adr_i    => wb_adr_s(wb_address_width_c-1 downto 0),
		-- wb_dat_i    => wb_dat_o_s,
		-- wb_we_i        => wb_we_s,
		-- wb_stb_i    => wb_stb_s,
		-- wb_cyc_i    => wb_cyc_s,
		-- wb_lock_i    => wb_stb_s,
		
		-- -- Wishbone Slave out
		-- wb_dat_o    => wb_dat_i_s,
		-- wb_ack_o    => wb_ack_s
	-- );
	
	p2l_dma:p2l_dma_master
	  generic map (
		-- Enable byte swap module (if false, no swap)
		g_BYTE_SWAP => false
		)
	  port map
		(
		  ---------------------------------------------------------
		  -- GN4124 core clock and reset
		  clk_i   => clk_i,
		  rst_n_i => not rst_i,

		  ---------------------------------------------------------
		  -- From the DMA controller
		  dma_ctrl_carrier_addr_i => dma_ctrl_carrier_addr_s,
		  dma_ctrl_host_addr_h_i  => dma_ctrl_host_addr_h_s,
		  dma_ctrl_host_addr_l_i  => dma_ctrl_host_addr_l_s,
		  dma_ctrl_len_i          => dma_ctrl_len_s,
		  dma_ctrl_start_p2l_i    => dma_ctrl_start_p2l_s,
		  dma_ctrl_start_next_i   => dma_ctrl_start_next_s,
		  dma_ctrl_done_o         => dma_ctrl_done_s,
		  dma_ctrl_error_o        => dma_ctrl_error_s,
		  dma_ctrl_byte_swap_i    => "111",
		  dma_ctrl_abort_i        => dma_ctrl_abort_s,

		  ---------------------------------------------------------
		  -- From P2L Decoder (receive the read completion)
		  --
		  -- Header
		  --pd_pdm_hdr_start_i   : in std_logic;                      -- Header strobe
		  --pd_pdm_hdr_length_i  : in std_logic_vector(9 downto 0);   -- Packet length in 32-bit words multiples
		  --pd_pdm_hdr_cid_i     : in std_logic_vector(1 downto 0);   -- Completion ID
		  pd_pdm_master_cpld_i => '1',                      -- Master read completion with data
		  pd_pdm_master_cpln_i => '0',                      -- Master read completion without data
		  --
		  -- Data
		  pd_pdm_data_valid_i  => pd_pdm_data_valid_s,                      -- Indicates Data is valid
		  pd_pdm_data_last_i   => pd_pdm_data_last_s,                      -- Indicates end of the packet
		  pd_pdm_data_i        => pd_pdm_data_s,  -- Data
		  pd_pdm_be_i          => X"FF",   -- Byte Enable for data TODO

		  ---------------------------------------------------------
		  -- P2L control
		  p2l_rdy_o  => open,      -- De-asserted to pause transfer already in progress
		  rx_error_o => open,       -- Asserted when transfer is aborted

		  ---------------------------------------------------------
		  -- To the P2L Interface (send the DMA Master Read request)
		  pdm_arb_tvalid_o  => pdm_arb_tvalid_s,  -- Read completion signals
		  pdm_arb_tlast_o => pdm_arb_tlast_s,  -- Toward the arbiter
		  pdm_arb_tdata_o   => pdm_arb_tdata_s,
		  pdm_arb_req_o    => pdm_arb_req_s,
		  arb_pdm_gnt_i    => pdm_arb_tready_s,

		  ---------------------------------------------------------
		  -- DMA Interface (Pipelined Wishbone)
		  p2l_dma_clk_i   => clk_i,                      -- Bus clock
		  p2l_dma_adr_o   => p2l_dma_adr_s,  -- Adress
		  p2l_dma_dat_i   => p2l_dma_dat_s2m_s,  -- Data in
		  p2l_dma_dat_o   => p2l_dma_dat_m2s_s,  -- Data out
		  p2l_dma_sel_o   => p2l_dma_sel_s,   -- Byte select
		  p2l_dma_cyc_o   => p2l_dma_cyc_s,                      -- Read or write cycle
		  p2l_dma_stb_o   => p2l_dma_stb_s,                      -- Read or write strobe
		  p2l_dma_we_o    => p2l_dma_we_s,                      -- Write
		  p2l_dma_ack_i   => p2l_dma_ack_s,                      -- Acknowledge
		  p2l_dma_stall_i => p2l_dma_stall_s,                      -- for pipelined Wishbone
		  l2p_dma_cyc_i   => l2p_dma_cyc_s,                      -- L2P dma wb cycle (for bus arbitration)

		  ---------------------------------------------------------
		  -- To the DMA controller
		  next_item_carrier_addr_o => next_item_carrier_addr_s,
		  next_item_host_addr_h_o  => next_item_host_addr_h_s,
		  next_item_host_addr_l_o  => next_item_host_addr_l_s,
		  next_item_len_o          => next_item_len_s,
		  next_item_next_l_o       => next_item_next_l_s,
		  next_item_next_h_o       => next_item_next_h_s,
		  next_item_attrib_o       => next_item_attrib_s,
		  next_item_valid_o        => next_item_valid_s
		  );
		  
	p2l_ram:bram_wbs
	generic map (
		ADDR_WIDTH => wb_address_width_c,
		DATA_WIDTH => 64 
	)
	port map (
		-- SYS CON
		clk			=> clk_i,
		rst			=> rst_i,
		
		-- Wishbone Slave in
		wb_adr_i	=> p2l_dma_adr_s(wb_address_width_c - 1 downto 0),
		wb_dat_i	=> p2l_dma_dat_m2s_s,
		wb_we_i		=> p2l_dma_we_s,
		wb_stb_i	=> p2l_dma_stb_s,
		wb_cyc_i	=> p2l_dma_cyc_s,
		wb_lock_i	=> p2l_dma_stb_s,
		
		-- Wishbone Slave out
		wb_dat_o	=> p2l_dma_dat_s2m_s,
		wb_ack_o	=> p2l_dma_ack_s
	);
		  
	-----------------------------------------------------------------------------
	-- L2P DMA master
	-----------------------------------------------------------------------------
	dut1 : l2p_dma_master
	port map
	(
		clk_i   => clk_i,
		rst_n_i => not rst_i,

		dma_ctrl_target_addr_i => dma_ctrl_carrier_addr_s,
		dma_ctrl_host_addr_h_i => dma_ctrl_host_addr_h_s,
		dma_ctrl_host_addr_l_i => dma_ctrl_host_addr_l_s,
		dma_ctrl_len_i         => dma_ctrl_len_s,
		dma_ctrl_start_l2p_i   => dma_ctrl_start_l2p_s,
		dma_ctrl_done_o        => dma_ctrl_done_s,
		dma_ctrl_error_o       => dma_ctrl_error_s,
		dma_ctrl_byte_swap_i   => "000", --TODO
		dma_ctrl_abort_i       => dma_ctrl_abort_s,

		ldm_arb_tvalid_o  => ldm_arb_tvalid_s,
		ldm_arb_tlast_o => ldm_arb_tlast_s,
		ldm_arb_tdata_o   => ldm_arb_tdata_s,
		ldm_arb_tkeep_o   => ldm_arb_tkeep_s,
		ldm_arb_req_o    => ldm_arb_req_s,
		arb_ldm_gnt_i    => ldm_arb_tready_s,

		l2p_edb_o  => open,
		ldm_arb_tready_i => ldm_arb_tready_s,
		l2p_rdy_i  => '1',
		l2p_64b_address_i => '0',
		tx_error_i => '0',

		l2p_dma_clk_i   => clk_i,
		l2p_dma_adr_o   => l2p_dma_adr_s,
		l2p_dma_dat_i   => l2p_dma_dat_s2m_s,
		l2p_dma_dat_o   => l2p_dma_dat_m2s_s,
		l2p_dma_sel_o   => l2p_dma_sel_s,
		l2p_dma_cyc_o   => l2p_dma_cyc_s,
		l2p_dma_stb_o   => l2p_dma_stb_s,
		l2p_dma_we_o    => l2p_dma_we_s,
		l2p_dma_ack_i   => l2p_dma_ack_s,
		l2p_dma_stall_i => l2p_dma_stall_s,
		p2l_dma_cyc_i   => p2l_dma_cyc_s
	);
	

	l2p_ram:bram_wbs
	generic map (
		ADDR_WIDTH => wb_address_width_c,
		DATA_WIDTH => 64 
	)
	port map (
		-- SYS CON
		clk			=> clk_i,
		rst			=> rst_i,
		
		-- Wishbone Slave in
		wb_adr_i	=> l2p_dma_adr_s(wb_address_width_c - 1 downto 0),
		wb_dat_i	=> l2p_dma_dat_m2s_s,
		wb_we_i		=> l2p_dma_we_s,
		wb_stb_i	=> l2p_dma_stb_s,
		wb_cyc_i	=> l2p_dma_cyc_s,
		wb_lock_i	=> l2p_dma_stb_s,
		
		-- Wishbone Slave out
		wb_dat_o	=> l2p_dma_dat_s2m_s,
		wb_ack_o	=> l2p_dma_ack_s
	);
	
	arbiter:l2p_arbiter
	generic map(
		axis_data_width_c => axis_data_width_c
	)
	port map(
		---------------------------------------------------------
		-- GN4124 core clock and reset
		clk_i   => clk_i,
		rst_n_i => rst_n_s,
		
		---------------------------------------------------------
		-- From Wishbone master (wbm) to arbiter (arb)      
		wbm_arb_tdata_i => wbm_arb_tdata_s,
		wbm_arb_tkeep_i => wbm_arb_tkeep_s,
		wbm_arb_tlast_i => wbm_arb_tlast_s,
		wbm_arb_tvalid_i => wbm_arb_tvalid_s,
		wbm_arb_req_i => wbm_arb_req_s,
		wbm_arb_tready_o => wbm_arb_tready_s,
		
		---------------------------------------------------------
		-- From P2L DMA master (pdm) to arbiter (arb)
		pdm_arb_tdata_i => pdm_arb_tdata_s,
		pdm_arb_tkeep_i => X"FF", --TODO
		pdm_arb_tlast_i => pdm_arb_tlast_s,
		pdm_arb_tvalid_i => pdm_arb_tvalid_s,
		pdm_arb_req_i => pdm_arb_req_s,
		pdm_arb_tready_o => pdm_arb_tready_s,
		arb_pdm_gnt_o => open,
		
		---------------------------------------------------------
		-- From L2P DMA master (ldm) to arbiter (arb)
		ldm_arb_tdata_i => ldm_arb_tdata_s,
		ldm_arb_tkeep_i => ldm_arb_tkeep_s,
		ldm_arb_tlast_i => ldm_arb_tlast_s,
		ldm_arb_tvalid_i => ldm_arb_tvalid_s,
		ldm_arb_req_i    => ldm_arb_req_s,
		ldm_arb_tready_o => ldm_arb_tready_s,
		arb_ldm_gnt_o => open,
		
		---------------------------------------------------------
		-- From arbiter (arb) to pcie_tx (tx)
		axis_tx_tdata_o => m_axis_tx_tdata_s,
		axis_tx_tkeep_o => m_axis_tx_tkeep_s,
		axis_tx_tuser_o => m_axis_tx_tuser_s,
		axis_tx_tlast_o => m_axis_tx_tlast_s,
		axis_tx_tvalid_o => m_axis_tx_tvalid_s,
		axis_tx_tready_i => m_axis_tx_tready_s,
		
		eop_do => eop_s
	);
  
  front_led_o <= count_s(28 downto 25);
  usr_led_o <= '1' & usr_sw_i;

end Behavioral;
