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
        wb_data_width_c : integer := 64;
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
		Port (
			clk_i : in STD_LOGIC;
			rst_i : in STD_LOGIC;
			-- Slave AXI-Stream
			s_axis_rx_tdata_i : in STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
			s_axis_rx_tkeep_i : in STD_LOGIC_VECTOR (axis_data_width_c/8 - 1 downto 0);
			s_axis_rx_tuser_i : in STD_LOGIC_VECTOR (21 downto 0);
			s_axis_rx_tlast_i : in STD_LOGIC;
			s_axis_rx_tvalid_i : in STD_LOGIC;
			s_axis_rx_ready_o : out STD_LOGIC;
			-- Master AXI-Stream
			m_axis_tx_tdata_o : out STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
			m_axis_tx_tkeep_o : out STD_LOGIC_VECTOR (axis_data_width_c/8 - 1 downto 0);
			m_axis_tx_tuser_o : out STD_LOGIC_VECTOR (3 downto 0);
			m_axis_tx_tlast_o : out STD_LOGIC;
			m_axis_tx_tvalid_o : out STD_LOGIC;
			m_axis_tx_ready_i : in STD_LOGIC;
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
    
    component bram_wbs is
    generic (
        constant ADDR_WIDTH : integer := 16;
        constant DATA_WIDTH : integer := 32 
    );
    port (
        -- SYS CON
        clk            : in std_logic;
        rst            : in std_logic;
        
        -- Wishbone Slave in
        wb_adr_i            : in std_logic_vector(wb_address_width_c-1 downto 0);
        wb_dat_i            : in std_logic_vector(wb_data_width_c-1 downto 0);
        wb_we_i            : in std_logic;
        wb_stb_i            : in std_logic;
        wb_cyc_i            : in std_logic; 
        wb_lock_i        : in std_logic; -- nyi
        
        -- Wishbone Slave out
        wb_dat_o            : out std_logic_vector(wb_data_width_c-1 downto 0);
        wb_ack_o            : out std_logic        
    );
    end component;
    
    
    signal rst_n_s : std_logic;
    signal count_s : STD_LOGIC_VECTOR (28 downto 0);
    signal eop_s : std_logic;
    
    -- Wishbone bus
    signal wb_adr_s : STD_LOGIC_VECTOR (64 - 1 downto 0);
    signal wb_dat_o_s : STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
    signal wb_dat_i_s : STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
    signal wb_cyc_s : STD_LOGIC;
    signal wb_sel_s : STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
    signal wb_stb_s : STD_LOGIC;
    signal wb_we_s : STD_LOGIC;
    signal wb_ack_s : STD_LOGIC;
    
    -- Slave AXI-Stream
    signal s_axis_rx_tdata_s : STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
    signal s_axis_rx_tkeep_s : STD_LOGIC_VECTOR (axis_data_width_c/8 - 1 downto 0);
    signal s_axis_rx_tuser_s : STD_LOGIC_VECTOR (21 downto 0);
    signal s_axis_rx_tlast_s : STD_LOGIC;
    signal s_axis_rx_tvalid_s :STD_LOGIC;
    signal s_axis_rx_tready_s : STD_LOGIC;
    -- Master AXI-Stream
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
		s_axis_rx_ready_o => s_axis_rx_tready_s,
		s_axis_rx_tuser_i => s_axis_rx_tuser_s,
		s_axis_rx_tvalid_i => s_axis_rx_tvalid_s,
		-- Master AXI-Stream
		m_axis_tx_tdata_o => m_axis_tx_tdata_s,
		m_axis_tx_tkeep_o => m_axis_tx_tkeep_s,
		m_axis_tx_tuser_o => m_axis_tx_tuser_s,
		m_axis_tx_tlast_o => m_axis_tx_tlast_s,
		m_axis_tx_tvalid_o => m_axis_tx_tvalid_s,
		m_axis_tx_ready_i => m_axis_tx_tready_s,
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
        
	ram_csr:bram_wbs
	generic map (
		ADDR_WIDTH => wb_address_width_c,
		DATA_WIDTH => wb_data_width_c 
	)
	port map (
		-- SYS CON
		clk            => clk_i,
		rst            => rst_i,
		
		-- Wishbone Slave in
		wb_adr_i    => wb_adr_s(wb_address_width_c-1 downto 0),
		wb_dat_i    => wb_dat_o_s,
		wb_we_i        => wb_we_s,
		wb_stb_i    => wb_stb_s,
		wb_cyc_i    => wb_cyc_s,
		wb_lock_i    => wb_stb_s,
		
		-- Wishbone Slave out
		wb_dat_o    => wb_dat_i_s,
		wb_ack_o    => wb_ack_s
	);
	
  
  
  front_led_o <= count_s(28 downto 25);
  usr_led_o <= '1' & usr_sw_i;

end Behavioral;
