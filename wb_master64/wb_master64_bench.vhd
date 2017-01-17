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
		constant wb_address_width_c : integer := 64;
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
		-- L2P DMA
		signal pd_pdm_data_valid_s  : std_logic;                      -- Indicates Data is valid
        signal pd_pdm_data_last_s   : std_logic;                      -- Indicates end of the packet
        signal pd_pdm_data_s        : std_logic_vector(63 downto 0);  -- Data
		-- Wishbone Master
		signal wb_adr_s : STD_LOGIC_VECTOR (wb_address_width_c - 1 downto 0);
		signal wb_dat_o_s : STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
		signal wb_dat_i_s : STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
		signal wb_cyc_s : STD_LOGIC;
		signal wb_sel_s : STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
		signal wb_stb_s : STD_LOGIC;
		signal wb_we_s : STD_LOGIC;
		signal wb_ack_s : STD_LOGIC;
		type tlp_type_t is (MRd,MRdLk,MWr,IORd,IOWr,CfgRd0,CfgWr0,CfgRd1,CfgWr1,TCfgRd,TCfgWr,Msg,MsgD,Cpl,CplD,CplLk,CplDLk,LPrfx,unknown);
		type header_t is (H3DW,H4DW);
		-- Test bench specific signals
		signal step : integer;
		
		procedure axis_data_p (
			tlp_type_i : in tlp_type_t;
			header_type_i : in header_t;
			address_i : in STD_LOGIC_VECTOR(wb_address_width_c-1 downto 0); 
			data_i : in STD_LOGIC_VECTOR(64-1 downto 0);
			length_i : in STD_LOGIC_VECTOR(10-1 downto 0); 
			rx_data_0 : out STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
			rx_data_1 : out STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
			rx_data_2 : out STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0)
			) is
		begin
			rx_data_0(63 downto 48) := X"0000"; --H1 Requester ID
			rx_data_0(47 downto 40) := X"00"; --H1 Tag 
			
			if length_i = "00" & X"01" then
				rx_data_0(39 downto 32) := X"0f"; --H1 Tag and Last DW BE and 1st DW BE see ch. 2.2.5 pcie spec
			else
				rx_data_0(39 downto 32) := X"ff";
			end if;
			
			case tlp_type_i is
				when MRd =>
					if header_type_i = H3DW then
						rx_data_0(31 downto 29) := "000"; -- H0 FMT
					else
						rx_data_0(31 downto 29) := "001"; -- H0 FMT
					end if;
					rx_data_0(28 downto 24) := "00000"; -- H0 type Memory request
				when MWr =>
					if header_type_i = H3DW then
						rx_data_0(31 downto 29) := "010"; -- H0 FMT
					else
						rx_data_0(31 downto 29) := "011"; -- H0 FMT
					end if;
					rx_data_0(28 downto 24) := "00000"; -- H0 type Memory request
				when CplD =>
					rx_data_0(31 downto 29) := "010"; -- H0 FMT
					rx_data_0(28 downto 24) := "01010"; -- H0 type Memory request
				when others =>
				
				
			end case;
			
			
			
			
			rx_data_0(23 downto 16) := X"00";   -- some unused bits
			rx_data_0(15 downto 10) := "000000"; --H0 unused bits 
			rx_data_0(9 downto 0) := length_i;  --H0 length H & length L
			
			if header_type_i = H3DW then
				rx_data_1(63 downto 32) := data_i(31 downto 0); --D0 Data
				rx_data_1(31 downto 0)	:= address_i(31 downto 0);  --H2 Adress	
				rx_data_2 := (others => '0');
			else
				rx_data_1(63 downto 32) := address_i(31 downto 0); --H3 Adress L (Last 4 bit must always pull at zero, byte to 8 byte)
				rx_data_1(31 downto 0)	:= address_i(63 downto 32);  --H2 Adress H
				rx_data_2 := data_i;
			end if;
			

			

			
		end axis_data_p;
		
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
			wb_adr_i			: in std_logic_vector(6-1 downto 0);
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
		variable data_0 : STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
		variable data_1 : STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
		variable data_2 : STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
	begin
		step <= 1;
		s_axis_rx_tdata_tbs <= (others => '0');
		s_axis_rx_tkeep_tbs <= (others => '0');
		s_axis_rx_tlast_tbs <= '0';
		s_axis_rx_tuser_tbs <= (others => '0');
		s_axis_rx_tvalid_tbs <= '0';
		m_axis_tx_ready_tbs <= '1';
		wait for period;
		
		wait for period;
		step <= 2;
		axis_data_p (MWr,H3DW,X"0000000000000000",X"00000000" & X"BEEF5A5A","00" & X"01",data_0,data_1,data_2);
		s_axis_rx_tdata_tbs <= data_0;
		--s_axis_rx_tdata_tbs <= X"0000" & --H1 Requester ID
		--					   X"00" & X"0f" & --H1 Tag and Last DW BE and 1st DW BE
		--					   "010" & "00000" & X"00" &  -- H0 FMT & type & some unused bits -- X"4000" &
		--					   "000000" & "00" & X"01";  --H0 unused bits & length H & length L
		s_axis_rx_tkeep_tbs <= X"FF";
		s_axis_rx_tlast_tbs <= '0';
		s_axis_rx_tuser_tbs <= "11" & X"e4004";
		s_axis_rx_tvalid_tbs <= '1';
		m_axis_tx_ready_tbs <= '1';	

		wait for period;
		step <= 3;
		s_axis_rx_tdata_tbs <= data_1;
		--s_axis_rx_tdata_tbs <= X"BEEF5A5A" & --H3 Adress L (Last 4 bit must always pull at zero, byte to 8 byte)
		--					   X"f7d08000";  --H2 Adress H 
		s_axis_rx_tkeep_tbs <= X"FF";
		s_axis_rx_tlast_tbs <= '1';
		s_axis_rx_tuser_tbs <= "10" & X"e4004";
		s_axis_rx_tvalid_tbs <= '1';
		m_axis_tx_ready_tbs <= '1';
		
		
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
		axis_data_p (MRd,H3DW,X"0000000000000000",X"00000000" & X"BEEF5A5A","00" & X"00",data_0,data_1,data_2);
		s_axis_rx_tdata_tbs <= data_0;
		--s_axis_rx_tdata_tbs <= X"0000000f" & X"00000001";
		s_axis_rx_tkeep_tbs <= X"FF";
		s_axis_rx_tlast_tbs <= '0';
		s_axis_rx_tuser_tbs <= "00" & X"e4004";
		s_axis_rx_tvalid_tbs <= '1';
		m_axis_tx_ready_tbs <= '1';
		wait for period;
		step <= 7;
		
		s_axis_rx_tdata_tbs <= data_1;
		--s_axis_rx_tdata_tbs <= X"592eaa50" & X"f7d08000";
		s_axis_rx_tkeep_tbs <= X"FF";
		s_axis_rx_tlast_tbs <= '1';
		s_axis_rx_tuser_tbs <= "11" & X"60004";
		s_axis_rx_tvalid_tbs <= '1';
		m_axis_tx_ready_tbs <= '1';
		wait for period;
		s_axis_rx_tdata_tbs <= X"0000000000A00001";
		s_axis_rx_tkeep_tbs <= X"FF";
		s_axis_rx_tlast_tbs <= '0';
		s_axis_rx_tuser_tbs <= "11" & X"60000";
		s_axis_rx_tvalid_tbs <= '0';
		m_axis_tx_ready_tbs <= '1';
		wait for period;
		wait for period;
		step <= 8;
		wait for period;
		wait for period;
		m_axis_tx_ready_tbs <= '0';
		wait for period;
		m_axis_tx_ready_tbs <= '1';
		step <= 9;
		wait for period;
		-- wait for period;
		-- wait for period;
		-- step <= 10;
		-- axis_data_p (MWr,H4DW,X"0000000000000010",X"CACA5A5A" & X"BEEF5A5A","00" & X"02",data_0,data_1,data_2);
		-- s_axis_rx_tdata_tbs <= data_0;
		-- s_axis_rx_tkeep_tbs <= X"FF";
		-- s_axis_rx_tlast_tbs <= '0';
		-- s_axis_rx_tuser_tbs <= "11" & X"60004";
		-- s_axis_rx_tvalid_tbs <= '1';
		-- m_axis_tx_ready_tbs <= '1';
		-- wait for period;
		-- step <= 11;
		-- s_axis_rx_tdata_tbs <= data_1;
		-- s_axis_rx_tkeep_tbs <= X"FF";
		-- s_axis_rx_tlast_tbs <= '0';
		-- s_axis_rx_tuser_tbs <= "11" & X"60004";
		-- s_axis_rx_tvalid_tbs <= '1';
		-- m_axis_tx_ready_tbs <= '1';
		-- wait for period;
		-- step <= 12;
		-- s_axis_rx_tdata_tbs <= data_2;
		-- s_axis_rx_tkeep_tbs <= X"FF";
		-- s_axis_rx_tlast_tbs <= '1';
		-- s_axis_rx_tuser_tbs <= "11" & X"60004";
		-- s_axis_rx_tvalid_tbs <= '1';
		-- m_axis_tx_ready_tbs <= '1';
		-- wait for period;
		-- step <= 12;
		-- s_axis_rx_tdata_tbs <= X"0000000000A00001";
		-- s_axis_rx_tkeep_tbs <= X"FF";
		-- s_axis_rx_tlast_tbs <= '0';
		-- s_axis_rx_tuser_tbs <= "11" & X"60000";
		-- s_axis_rx_tvalid_tbs <= '0';
		-- m_axis_tx_ready_tbs <= '1';
		-- wait for period;
		-- step <= 13;
		-- wait for period;
		-- wait for period;
		-- step <= 14;
		-- axis_data_p (MRd,H4DW,X"0000000000000010",X"BEEF5A5A" & X"CACA5A5A","00" & X"00",data_0,data_1,data_2);
		-- s_axis_rx_tdata_tbs <= data_0;
		-- s_axis_rx_tkeep_tbs <= X"FF";
		-- s_axis_rx_tlast_tbs <= '0';
		-- s_axis_rx_tuser_tbs <= "11" & X"60004";
		-- s_axis_rx_tvalid_tbs <= '1';
		-- m_axis_tx_ready_tbs <= '1';
		-- wait for period;
		-- step <= 15;
		-- s_axis_rx_tdata_tbs <= data_1;
		-- s_axis_rx_tkeep_tbs <= X"FF";
		-- s_axis_rx_tlast_tbs <= '1';
		-- s_axis_rx_tuser_tbs <= "11" & X"60004";
		-- s_axis_rx_tvalid_tbs <= '1';
		-- m_axis_tx_ready_tbs <= '1';
		-- wait for period;
		-- step <= 16;
		-- s_axis_rx_tdata_tbs <= X"0000000000A00001";
		-- s_axis_rx_tkeep_tbs <= X"FF";
		-- s_axis_rx_tlast_tbs <= '0';
		-- s_axis_rx_tuser_tbs <= "11" & X"60000";
		-- s_axis_rx_tvalid_tbs <= '0';
		-- m_axis_tx_ready_tbs <= '1';
		-- wait for period;
		-- wait for period;
		-- wait for period;
		-- wait for period;
		-- wait for period;
	    wait for period;
		step <= 17;
		axis_data_p (CplD,H3DW,X"0000000000000010",X"BEEF5A5A" & X"BEEF0001","00" & X"04",data_0,data_1,data_2);
		s_axis_rx_tdata_tbs <= data_0;
		s_axis_rx_tkeep_tbs <= X"FF";
		s_axis_rx_tlast_tbs <= '0';
		s_axis_rx_tuser_tbs <= "11" & X"60004";
		s_axis_rx_tvalid_tbs <= '1';
		m_axis_tx_ready_tbs <= '1';
		wait for period;
		step <= 18;
		s_axis_rx_tdata_tbs <= data_1;
		wait for period;
		s_axis_rx_tdata_tbs <=  X"BEEF0002" & X"DEAD0001";
		wait for period;
		s_axis_rx_tdata_tbs <=  X"CACA0003" & X"DEAD0002";
		s_axis_rx_tkeep_tbs <= X"0F";
		s_axis_rx_tlast_tbs <= '1';
		
		
		
		-- step <= 18;
		
		wait for period;
		step <= 19;
		s_axis_rx_tdata_tbs <= X"000F000000A00001";
		s_axis_rx_tkeep_tbs <= X"FF";
		s_axis_rx_tlast_tbs <= '0';
		s_axis_rx_tuser_tbs <= "11" & X"60000";
		s_axis_rx_tvalid_tbs <= '0';
		m_axis_tx_ready_tbs <= '1';
		wait;
		
	end process stimuli_p;
	
	dut1:wb_master64
	Generic map(
		axis_data_width_c => 64,
		wb_address_width_c => 64,
		wb_data_width_c => 32,
		address_mask_c => X"00000000" & X"000000FF" -- depends on pcie memory size
	)
	port map(
		clk_i => clk_tbs,
		rst_i => rst_tbs,
		-- Slave AXI-Stream
		s_axis_rx_tdata_i => s_axis_rx_tdata_tbs,
		s_axis_rx_tkeep_i => s_axis_rx_tkeep_tbs,
		s_axis_rx_tlast_i => s_axis_rx_tlast_tbs,
		s_axis_rx_tready_o => s_axis_rx_ready_s,
		s_axis_rx_tuser_i => s_axis_rx_tuser_tbs,
		s_axis_rx_tvalid_i => s_axis_rx_tvalid_tbs,
		-- Master AXI-Stream
		wbm_arb_tdata_o => m_axis_tx_tdata_s,
		wbm_arb_tkeep_o => m_axis_tx_tkeep_s,
		wbm_arb_tuser_o => m_axis_tx_tuser_s,
		wbm_arb_tlast_o => m_axis_tx_tlast_s,
		wbm_arb_tvalid_o => m_axis_tx_tvalid_s,
		wbm_arb_tready_i => m_axis_tx_ready_tbs,
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
	
	dut2:bram_wbs
	generic map (
		ADDR_WIDTH => 6,
		DATA_WIDTH => wb_data_width_c 
	)
	port map (
		-- SYS CON
		clk			=> clk_tbs,
		rst			=> rst_tbs,
		
		-- Wishbone Slave in
		wb_adr_i	=> wb_adr_s(9 downto 4),
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