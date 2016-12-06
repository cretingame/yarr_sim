library IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;
use IEEE.std_logic_unsigned.all; 


entity wb_master64_bench is
    generic (
		constant period : time := 100 ns;
		constant axis_data_width_c : integer := 64;
		constant axis_rx_tkeep_width_c : integer := 64/8;
		constant axis_rx_tuser_width_c : integer := 22;
		constant wb_address_width_c : integer := 8;
		constant wb_data_width_c : integer := 32
	);
	--port ();
end wb_master64_bench;

architecture Behavioral of wb_master64_bench is
		signal clk_tbs : STD_LOGIC;
		signal rst_tbs : STD_LOGIC;
		-- Slave AXI-Stream
		signal s_axis_rx_tdata_tbs : STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
		signal s_axis_rx_tkeep_tbs : STD_LOGIC_VECTOR (axis_rx_tkeep_width_c - 1 downto 0);
		signal s_axis_rx_tlast_tbs : STD_LOGIC;
		signal s_axis_rx_ready_s : STD_LOGIC;
		signal s_axis_rx_tuser_tbs : STD_LOGIC_VECTOR (axis_rx_tuser_width_c - 1 downto 0);
		signal s_axis_rx_tvalid_tbs : STD_LOGIC;
		-- Master AXI-Stream
		signal m_axis_tx_tdata_s : STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
		signal m_axis_tx_tkeep_s : STD_LOGIC_VECTOR (axis_data_width_c/8 - 1 downto 0);
		signal m_axis_tx_tuser_s : STD_LOGIC_VECTOR (3 downto 0);
		signal m_axis_tx_tlast_s : STD_LOGIC;
		signal m_axis_tx_tvalid_s : STD_LOGIC;
		signal m_axis_tx_ready_tbs : STD_LOGIC;
		-- Wishbone Master
		signal wb_adr_s : STD_LOGIC_VECTOR (wb_address_width_c - 1 downto 0);
		signal wb_dat_o_s : STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
		signal wb_dat_i_s : STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
		signal wb_cyc_s : STD_LOGIC;
		signal wb_sel_s : STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
		signal wb_stb_s : STD_LOGIC;
		signal wb_we_s : STD_LOGIC;
		signal wb_ack_s : STD_LOGIC;
		-- Test bench specific signals
		signal step : integer range 1 to 10;
		
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
			-- Wishbone master
			wb_adr_o : out STD_LOGIC_VECTOR (wb_address_width_c - 1 downto 0);
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
			constant ADDR_WIDTH : integer := 32;
			constant DATA_WIDTH : integer := 15 
		);
		port (
			-- SYS CON
			clk			: in std_logic;
			rst			: in std_logic;
			
			-- Wishbone Slave in
			wb_adr_i			: in std_logic_vector(wb_address_width_c-1 downto 0);
			wb_dat_i			: in std_logic_vector(wb_data_width_c-1 downto 0);
			wb_we_i			: in std_logic;
			wb_stb_i			: in std_logic;
			wb_cyc_i			: in std_logic; 
			wb_lock_i		: in std_logic; -- nyi
			
			-- Wishbone Slave out
			wb_dat_o			: out std_logic_vector(wb_data_width_c-1 downto 0);
			wb_ack_o			: out std_logic		
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
		m_axis_tx_ready_tbs <= '1';
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
		m_axis_tx_ready_tbs <= '1';
		--wb_ack_s <= '0';		

		wait for period;
		step <= 3;
		s_axis_rx_tdata_tbs <= X"BEEF5A5A" & --H3 Adress L (Last 4 bit must always pull at zero, byte to 8 byte)
							   X"f7d08000";  --H2 Adress H 
		s_axis_rx_tkeep_tbs <= X"FF";
		s_axis_rx_tlast_tbs <= '1';
		s_axis_rx_tuser_tbs <= "10" & X"e4004";
		s_axis_rx_tvalid_tbs <= '1';
		m_axis_tx_ready_tbs <= '1';
		--wb_ack_s <= '0';
		
		wait for period;
		step <= 4;
		s_axis_rx_tdata_tbs <= X"0000000000000001";
		s_axis_rx_tkeep_tbs <= X"FF";
		s_axis_rx_tlast_tbs <= '0';
		s_axis_rx_tuser_tbs <= "11" & X"60000";
		s_axis_rx_tvalid_tbs <= '0';
		m_axis_tx_ready_tbs <= '1';
		--wb_ack_s <= '0';
		wait for period;
		step <= 5;
		s_axis_rx_tdata_tbs <= X"0000000000000001";
		s_axis_rx_tkeep_tbs <= X"FF";
		s_axis_rx_tlast_tbs <= '0';
		s_axis_rx_tuser_tbs <= "11" & X"60000";
		s_axis_rx_tvalid_tbs <= '0';
		m_axis_tx_ready_tbs <= '1';
		--wb_ack_s <= '1';
		wait for period;
		wait for period;
		wait for period;
		step <= 6;
		--wait until s_axis_rx_ready_o = '1';
		s_axis_rx_tdata_tbs <= X"0000000f" & X"00000001";
		s_axis_rx_tkeep_tbs <= X"FF";
		s_axis_rx_tlast_tbs <= '0';
		s_axis_rx_tuser_tbs <= "00" & X"e4004";
		s_axis_rx_tvalid_tbs <= '1';
		m_axis_tx_ready_tbs <= '1';
		wait for period;
		step <= 7;
		--wait until s_axis_rx_ready_o = '1';
		s_axis_rx_tdata_tbs <= X"592eaa50" & X"f7d08000";
		s_axis_rx_tkeep_tbs <= X"FF";
		s_axis_rx_tlast_tbs <= '1';
		s_axis_rx_tuser_tbs <= "11" & X"60004";
		s_axis_rx_tvalid_tbs <= '1';
		m_axis_tx_ready_tbs <= '1';
		wait for period;
		wait for period;
		wait for period;
		step <= 8;
		wait for period;
		wait for period;
		m_axis_tx_ready_tbs <= '0';
		wait for period;
		m_axis_tx_ready_tbs <= '1';
		step <= 9;
		wait;
		
	end process stimuli_p;
	
	dut1:wb_master64
	port map(
		clk_i => clk_tbs,
		rst_i => rst_tbs,
		-- Slave AXI-Stream
		s_axis_rx_tdata_i => s_axis_rx_tdata_tbs,
		s_axis_rx_tkeep_i => s_axis_rx_tkeep_tbs,
		s_axis_rx_tlast_i => s_axis_rx_tlast_tbs,
		s_axis_rx_ready_o => s_axis_rx_ready_s,
		s_axis_rx_tuser_i => s_axis_rx_tuser_tbs,
		s_axis_rx_tvalid_i => s_axis_rx_tvalid_tbs,
		-- Master AXI-Stream
		m_axis_tx_tdata_o => m_axis_tx_tdata_s,
		m_axis_tx_tkeep_o => m_axis_tx_tkeep_s,
		m_axis_tx_tuser_o => m_axis_tx_tuser_s,
		m_axis_tx_tlast_o => m_axis_tx_tlast_s,
		m_axis_tx_tvalid_o => m_axis_tx_tvalid_s,
		m_axis_tx_ready_i => m_axis_tx_ready_tbs,
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
	
	dut2:bram_wbs
	generic map (
		ADDR_WIDTH => wb_address_width_c,
		DATA_WIDTH => wb_data_width_c 
	)
	port map (
		-- SYS CON
		clk			=> clk_tbs,
		rst			=> rst_tbs,
		
		-- Wishbone Slave in
		wb_adr_i	=> wb_adr_s,
		wb_dat_i	=> wb_dat_o_s,
		wb_we_i		=> wb_we_s,
		wb_stb_i	=> wb_stb_s,
		wb_cyc_i	=> wb_cyc_s,
		wb_lock_i	=> wb_stb_s,
		
		-- Wishbone Slave out
		wb_dat_o	=> wb_dat_i_s,
		wb_ack_o	=> wb_ack_s
	);
	
	
end Behavioral;