library IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;
use IEEE.std_logic_unsigned.all; 


entity top_bench is
    generic (
		constant period : time := 100 ns;
		constant axis_data_width_c : integer := 64;
		constant axis_rx_tkeep_width_c : integer := 64/8;
		constant axis_rx_tuser_width_c : integer := 22;
		constant wb_address_width_c : integer := 15;
		constant wb_data_width_c : integer := 32
	);
	--port ();
end top_bench;

architecture Behavioral of top_bench is
	signal clk_tbs : STD_LOGIC;
	signal rst_tbs : STD_LOGIC;
	
	signal usr_sw_tbs : STD_LOGIC_VECTOR (2 downto 0);
	signal usr_led_s : STD_LOGIC_VECTOR (3 downto 0);
	signal front_led_s : STD_LOGIC_VECTOR (3 downto 0);
	
	-- Slave AXI-Stream
	signal s_axis_rx_tdata_tbs : STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
	signal s_axis_rx_tkeep_tbs : STD_LOGIC_VECTOR (axis_rx_tkeep_width_c - 1 downto 0);
	signal s_axis_rx_tlast_tbs : STD_LOGIC;
	signal s_axis_rx_tready_s : STD_LOGIC;
	signal s_axis_rx_tuser_tbs : STD_LOGIC_VECTOR (axis_rx_tuser_width_c - 1 downto 0);
	signal s_axis_rx_tvalid_tbs : STD_LOGIC;
	-- Master AXI-Stream
	signal m_axis_tx_tdata_s : STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
	signal m_axis_tx_tkeep_s : STD_LOGIC_VECTOR (axis_data_width_c/8 - 1 downto 0);
	signal m_axis_tx_tuser_s : STD_LOGIC_VECTOR (3 downto 0);
	signal m_axis_tx_tlast_s : STD_LOGIC;
	signal m_axis_tx_tvalid_s : STD_LOGIC;
	signal m_axis_tx_tready_tbs : STD_LOGIC;
    
    -- PCIE signals
    signal user_lnk_up_s : STD_LOGIC;
    signal user_app_rdy_s : STD_LOGIC;
    signal cfg_interrupt_s : STD_LOGIC;
    signal cfg_interrupt_rdy_s : STD_LOGIC;
    signal cfg_interrupt_assert_s : STD_LOGIC;
    signal cfg_interrupt_di_s : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal cfg_interrupt_do_s : STD_LOGIC_VECTOR(7 DOWNTO 0);
    signal cfg_interrupt_mmenable_s : STD_LOGIC_VECTOR(2 DOWNTO 0);
    signal cfg_interrupt_msienable_s : STD_LOGIC;
    signal cfg_interrupt_msixenable_s : STD_LOGIC;
    signal cfg_interrupt_msixfm_s : STD_LOGIC;
    signal cfg_interrupt_stat_s : STD_LOGIC;
    signal cfg_pciecap_interrupt_msgnum_s : STD_LOGIC_VECTOR(4 DOWNTO 0);
	
	-- Test bench specific signals
	signal step : integer range 1 to 10;
	
	component app is
		Generic(
			AXI_BUS_WIDTH : integer := 64
			);
		Port ( 
		   clk_i : in STD_LOGIC;
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
	end component;
	
begin

	clk_p: process
	begin
		clk_tbs <= '1';
		wait for period/2;
		clk_tbs <= '0';
		wait for period/2;
	end process clk_p;
	
	reset_p: process
	begin
	   rst_tbs <= '1';
	   wait for period;
	   rst_tbs <= '0';
	   wait;
	end process reset_p;
	
	stimuli_p: process
	begin
		step <= 1;
		s_axis_rx_tdata_tbs <= (others => '0');
		s_axis_rx_tkeep_tbs <= (others => '0');
		s_axis_rx_tlast_tbs <= '0';
		s_axis_rx_tuser_tbs <= (others => '0');
		s_axis_rx_tvalid_tbs <= '0';
		m_axis_tx_tready_tbs <= '1';
		--wb_ack_s <= '0';
		wait for period;
		
		wait for period;
		step <= 2;
		s_axis_rx_tdata_tbs <= X"0000" & --H1 Requester ID
							   X"00" & X"0f" & --H1 Tag and Last DW BE and 1st DW BE
							   "010" & "00000" & X"00" &  -- H0 FMT & type & some unused bits -- X"4000" &
							   "000000" & "00" & X"01";  --H0 unused bits & length H & length L
		s_axis_rx_tkeep_tbs <= X"FF";
		s_axis_rx_tlast_tbs <= '0';
		s_axis_rx_tuser_tbs <= "11" & X"e4004";
		s_axis_rx_tvalid_tbs <= '1';
		m_axis_tx_tready_tbs <= '1';
		--wb_ack_s <= '0';
		wait for period;
		step <= 3;
		s_axis_rx_tdata_tbs <= X"a5a5a5a5f7d08000";
		s_axis_rx_tkeep_tbs <= X"0F";
		s_axis_rx_tlast_tbs <= '1';
		s_axis_rx_tuser_tbs <= "10" & X"e4004";
		s_axis_rx_tvalid_tbs <= '1';
		m_axis_tx_tready_tbs <= '1';
		--wb_ack_s <= '0';
		wait for period;
		step <= 4;
		s_axis_rx_tdata_tbs <= X"0000000000000001";
		s_axis_rx_tkeep_tbs <= X"FF";
		s_axis_rx_tlast_tbs <= '0';
		s_axis_rx_tuser_tbs <= "11" & X"60000";
		s_axis_rx_tvalid_tbs <= '0';
		m_axis_tx_tready_tbs <= '1';
		--wb_ack_s <= '0';
		wait for period;
		step <= 5;
		s_axis_rx_tdata_tbs <= X"0000000000000001";
		s_axis_rx_tkeep_tbs <= X"FF";
		s_axis_rx_tlast_tbs <= '0';
		s_axis_rx_tuser_tbs <= "11" & X"60000";
		s_axis_rx_tvalid_tbs <= '0';
		m_axis_tx_tready_tbs <= '1';
		--wb_ack_s <= '1';
		wait for period;
		wait for period;
		wait for period;
		step <= 6;
		--wait until s_axis_rx_ready_o = '1';
		s_axis_rx_tdata_tbs <= X"0000000f00000001";
		s_axis_rx_tkeep_tbs <= X"FF";
		s_axis_rx_tlast_tbs <= '0';
		s_axis_rx_tuser_tbs <= "00" & X"e4004";
		s_axis_rx_tvalid_tbs <= '1';
		m_axis_tx_tready_tbs <= '1';
		wait for period;
		step <= 7;
		--wait until s_axis_rx_ready_o = '1';
		s_axis_rx_tdata_tbs <= X"592eaa50f7d08000";
		s_axis_rx_tkeep_tbs <= X"FF";
		s_axis_rx_tlast_tbs <= '1';
		s_axis_rx_tuser_tbs <= "11" & X"60004";
		s_axis_rx_tvalid_tbs <= '1';
		m_axis_tx_tready_tbs <= '1';
		wait for period;
		wait for period;
		wait for period;
		wait for period;
		wait for period;
		wait for period;
		
		
	end process stimuli_p;
	

	app_0:app
	generic map(
		AXI_BUS_WIDTH => 64
	)
	port map(
		clk_i => clk_tbs,
		rst_i => rst_tbs,
		user_lnk_up_i => user_lnk_up_s,
		user_app_rdy_i => user_app_rdy_s,

		-- AXI-Stream bus
		m_axis_tx_tready_i => m_axis_tx_tready_tbs,
		m_axis_tx_tdata_o => m_axis_tx_tdata_s,
		m_axis_tx_tkeep_o => m_axis_tx_tkeep_s,
		m_axis_tx_tlast_o => m_axis_tx_tlast_s,
		m_axis_tx_tvalid_o => m_axis_tx_tvalid_s,
		m_axis_tx_tuser_o => m_axis_tx_tuser_s,
		s_axis_rx_tdata_i => s_axis_rx_tdata_tbs,
		s_axis_rx_tkeep_i => s_axis_rx_tkeep_tbs,
		s_axis_rx_tlast_i => s_axis_rx_tlast_tbs,
		s_axis_rx_tvalid_i => s_axis_rx_tvalid_tbs,
		s_axis_rx_tready_o => s_axis_rx_tready_s,
		s_axis_rx_tuser_i => s_axis_rx_tuser_tbs,

		-- PCIe interrupt config
		cfg_interrupt_o => cfg_interrupt_s,
		cfg_interrupt_rdy_i => cfg_interrupt_rdy_s,
		cfg_interrupt_assert_o => cfg_interrupt_assert_s,
		cfg_interrupt_di_o => cfg_interrupt_di_s,
		cfg_interrupt_do_i => cfg_interrupt_do_s,
		cfg_interrupt_mmenable_i => cfg_interrupt_mmenable_s,
		cfg_interrupt_msienable_i => cfg_interrupt_msienable_s,
		cfg_interrupt_msixenable_i => cfg_interrupt_msixenable_s,
		cfg_interrupt_msixfm_i => cfg_interrupt_msixfm_s,
		cfg_interrupt_stat_o => cfg_interrupt_stat_s,
		cfg_pciecap_interrupt_msgnum_o => cfg_pciecap_interrupt_msgnum_s,

		--I/O
		usr_sw_i => usr_sw_tbs,
		usr_led_o => usr_led_s,
		front_led_o => front_led_s
	);
	
	
	
end Behavioral;