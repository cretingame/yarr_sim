library IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

entity axis_rx is
	Generic (
		axis_data_width_c : integer := 64;
		--address_width_c : integer := 256;
		wb_address_width_c : integer := 15; -- 32k
		wb_data_width_c : integer := 32;
		address_mask_c : STD_LOGIC_VECTOR(32-1 downto 0) := X"000000FF"
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
		s_axis_rx_ready_o : out STD_LOGIC;
		-- Master AXI-Stream
		m_axis_tx_tdata_o : out STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
		m_axis_tx_tkeep_o : out STD_LOGIC_VECTOR (axis_data_width_c/8 - 1 downto 0);
		m_axis_tx_tuser_o : out STD_LOGIC_VECTOR (3 downto 0);
		m_axis_tx_tlast_o : out STD_LOGIC;
		m_axis_tx_tvalid_o : out STD_LOGIC;
		m_axis_tx_ready_i : in STD_LOGIC;
		m_axis_tx_req_o    : out  std_logic;
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
end axis_rx;

architecture Behavioral of axis_rx is
	type state_t is (idle, h1h0_rx, d0h2_rx, wb, ignore, wb_read, h1h0_tx, d0h2_tx, wait_1, wait_2);
	signal state_s : state_t;
	--signal wb_adr_s : STD_LOGIC_VECTOR (wb_address_width_c - 1 downto 0);
	signal wb_dat_o_s : STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
	signal wb_we_s : STD_LOGIC;
	signal length_s : STD_LOGIC_VECTOR(9 downto 0);
	signal bar_hit_s : STD_LOGIC_VECTOR(6 downto 0);
	type tlp_type_t is (MRd,MRdLk,MWr,IORd,IOWr,CfgRd0,CfgWr0,CfgRd1,CfgWr1,TCfgRd,TCfgWr,Msg,MsgD,Cpl,CplD,CplLk,CplDLk,LPrfx,unknown);
	signal tlp_type_s : tlp_type_t;
	type header_t is (H3DW,H4DW);
	signal header_type_s : header_t;
	type bool_t is (false,true);
	signal payload_s : bool_t;
	signal tlp_prefix : bool_t;
	signal address_s : STD_LOGIC_VECTOR(30-1 downto 0);
	signal data_s : STD_LOGIC_VECTOR(32-1 downto 0);
	signal s_axis_rx_tdata_s : STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
	signal s_axis_rx_tkeep_s : STD_LOGIC_VECTOR (axis_data_width_c/8 - 1 downto 0);
	signal s_axis_rx_tuser_s : STD_LOGIC_VECTOR (21 downto 0);
	signal m_axis_tx_tdata_s : STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
	signal wb_dat_i_s : STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
begin


	state_p:process(rst_i,clk_i) 
	begin
		if rst_i = '1' then
			state_s <= idle;
		elsif clk_i = '1' and clk_i'event then
			case state_s is
				when idle =>
					if s_axis_rx_tvalid_i = '1' then
						state_s <= h1h0_rx;
					else
						state_s <= idle;
					end if;
				when h1h0_rx =>
					if s_axis_rx_tvalid_i = '1' and s_axis_rx_tlast_i = '1' then
						state_s <= d0h2_rx;
					elsif s_axis_rx_tvalid_i = '1' and s_axis_rx_tlast_i = '0' then
						state_s <= ignore;
					else
						state_s <= h1h0_rx;
					end if;
				when d0h2_rx =>
					state_s <= wb;
				when wb =>
					if wb_ack_i = '1' and wb_we_s = '1' then
						state_s <= idle;
					elsif wb_ack_i = '1' and wb_we_s = '0' then
						state_s <= wb_read;
					else
						state_s <= wb;
					end if;
				when ignore =>
					if s_axis_rx_tvalid_i = '1' then
						state_s <= ignore;
					else
						state_s <= idle;
					end if;
				when wb_read =>
				    --state_s <= h1h0_tx;
					if m_axis_tx_ready_i = '1' then
						state_s <= h1h0_tx;
					else
						state_s <= wait_1;
					end if;
				when h1h0_tx => 
					if m_axis_tx_ready_i = '1' then
						state_s <= d0h2_tx;
					else
						state_s <= wait_2;
					end if;
				when d0h2_tx =>
                    if m_axis_tx_ready_i = '1' then
                        state_s <= idle;
                    else
                        state_s <= d0h2_tx;
                    end if;
					--state_s <= idle;
				when wait_1 =>
                    if m_axis_tx_ready_i = '1' then
                        state_s <= h1h0_tx;
                    else
                        state_s <= wait_1;
                    end if;
				when wait_2 =>
                    if m_axis_tx_ready_i = '1' then
                        state_s <= d0h2_tx;
                    else
                        state_s <= wait_2;
                    end if;
			end case;
		end if;		
	end process state_p;
	
	delay_p: process(clk_i)
	begin
		if clk_i = '1' and clk_i'event then
			s_axis_rx_tdata_s <= s_axis_rx_tdata_i;
			s_axis_rx_tkeep_s <= s_axis_rx_tkeep_i;
			s_axis_rx_tuser_s <= s_axis_rx_tuser_i;
			wb_dat_i_s <= wb_dat_i;
		end if;
	end process delay_p;
	
	reg_p: process(rst_i,clk_i)
		variable tlp_v : STD_LOGIC_VECTOR (7 downto 0);
	begin
		if rst_i = '1' then
			--wb_adr_o <= (others => '0');
			wb_dat_o_s <= (others => '0');
			address_s <= (others => '0');
			tlp_type_s <= unknown;
			header_type_s <= H4DW;
			wb_we_s <= '0';
		elsif clk_i = '1' and clk_i'event then
			case state_s is
				when h1h0_rx =>

					bar_hit_s <= s_axis_rx_tuser_s(8 downto 2);
					length_s <= s_axis_rx_tdata_s(9 downto 0);
					tlp_v := s_axis_rx_tdata_s(31 downto 24);
					case s_axis_rx_tdata_s(31 downto 24) is
						when "00000000" =>
							tlp_type_s <= MRd;
							header_type_s <= H3DW;
							wb_we_s <= '0';
						when "00100000" =>
							tlp_type_s <= MRd;
							header_type_s <= H4DW;
							wb_we_s <= '0';
						when "00000001" =>
							tlp_type_s <= MRdLk;
							header_type_s <= H3DW;
							wb_we_s <= '0';
						when "00100001" =>
							tlp_type_s <= MRdLk;
							header_type_s <= H4DW;
							wb_we_s <= '0';
						when "01000000" =>
							tlp_type_s <= MWr;
							header_type_s <= H3DW;
							wb_we_s <= '1';
						when "01100000" =>
							tlp_type_s <= MWr;	
							header_type_s <= H4DW;
							wb_we_s <= '1';
						when "00000010" =>
							tlp_type_s <= IORd;
							header_type_s <= H3DW;
							wb_we_s <= '0';
						when "01000010" =>
							tlp_type_s <= IOWr;
							header_type_s <= H3DW;
							wb_we_s <= '0';
						when "00000100" =>
							tlp_type_s <= CfgRd0;
							header_type_s <= H3DW;
							wb_we_s <= '0';
						when "01000100" =>
							tlp_type_s <= CfgWr0;
							header_type_s <= H3DW;
							wb_we_s <= '0';
						when "00000101" =>
							tlp_type_s <= CfgRd1;
							header_type_s <= H3DW;
							wb_we_s <= '0';
						when "01000101" =>
							tlp_type_s <= CfgWr1;
							header_type_s <= H3DW;
							wb_we_s <= '0';
						when "00011011" =>
							tlp_type_s <= TCfgRd;
							header_type_s <= H3DW;
							wb_we_s <= '0';
						when "01011011" =>
							tlp_type_s <= TCfgWr;
							header_type_s <= H3DW;
							wb_we_s <= '0';
						when "00001010" =>
							tlp_type_s <= Cpl;
							header_type_s <= H3DW;
							wb_we_s <= '0';
						when "01001010" =>
							tlp_type_s <= CplD;
							header_type_s <= H3DW;
							wb_we_s <= '0';
						when "00001011" =>
							tlp_type_s <= CplLk;
							header_type_s <= H3DW;
							wb_we_s <= '0';
						when "01001011" =>
							tlp_type_s <= CplDLk;
							header_type_s <= H3DW;
							wb_we_s <= '0';

						when others =>
							if s_axis_rx_tdata_s(31 downto 27) = "00110" then
								tlp_type_s <= Msg;
								header_type_s <= H4DW;
								wb_we_s <= '0';
							elsif s_axis_rx_tdata_s(31 downto 27) = "01110" then
								tlp_type_s <= MsgD;
								header_type_s <= H4DW;
								wb_we_s <= '0';
							elsif s_axis_rx_tdata_s(31 downto 28) = "1000" then
								tlp_type_s <= LPrfx;
								header_type_s <= H3DW;
								wb_we_s <= '0';
							else
								tlp_type_s <= unknown;
								header_type_s <= H4DW;
								wb_we_s <= '0';
							end if;
					end case;
				when d0h2_rx =>
					wb_dat_o_s <= s_axis_rx_tdata_s(63 downto 32);
					--address_s <= s_axis_rx_tdata_s(31 downto 2) and address_mask_c;
					address_s <= s_axis_rx_tdata_s(31 downto 2) and address_mask_c(29 downto 0);
					--for i in 30-1 to wb_address_width_c loop
						--address_s(i) <= '0';
					--end loop;
					
				when wb_read =>
					data_s <= wb_dat_i_s;
				when h1h0_tx => 
					
				when others =>

			end case;
		end if;
	end process reg_p;
	
	wb_adr_o <= address_s(wb_address_width_c-1 downto 0);
	wb_dat_o <= wb_dat_o_s;
	
	output_p:process (state_s)
	begin
		case state_s is
				when idle =>
					s_axis_rx_ready_o <= '1';
					m_axis_tx_tvalid_o <= '0';
					m_axis_tx_tlast_o <= '0';
					m_axis_tx_tdata_o <= (others => '0');
					m_axis_tx_req_o <= '0';
					wb_cyc_o <= '0';
					wb_stb_o <= '0';
					wb_we_o <= '0';
				when h1h0_rx =>
					s_axis_rx_ready_o <= '1';
					m_axis_tx_tvalid_o <= '0';
					m_axis_tx_tlast_o <= '0';
					m_axis_tx_tdata_o <= (others => '0');
					m_axis_tx_req_o <= '0';
					wb_cyc_o <= '0';
					wb_stb_o <= '0';
					wb_we_o <= '0';
				when d0h2_rx =>
					s_axis_rx_ready_o <= '0';
					m_axis_tx_tvalid_o <= '0';
					m_axis_tx_tlast_o <= '0';
					m_axis_tx_tdata_o <= (others => '0');
					m_axis_tx_req_o <= '0';
					wb_cyc_o <= '0';
					wb_stb_o <= '0';
					wb_we_o <= '0';
				when wb =>
					s_axis_rx_ready_o <= '0';
					m_axis_tx_tvalid_o <= '0';
					m_axis_tx_tlast_o <= '0';
					m_axis_tx_tdata_o <= (others => '0');
					m_axis_tx_req_o <= '0';
					wb_cyc_o <= '1';
					wb_stb_o <= '1';
					wb_we_o <= wb_we_s;
				when ignore =>
					s_axis_rx_ready_o <= '1';
					m_axis_tx_tvalid_o <= '0';
					m_axis_tx_tlast_o <= '0';
					m_axis_tx_tdata_o <= (others => '0');
					m_axis_tx_req_o <= '0';
					wb_cyc_o <= '0';
					wb_stb_o <= '0';
					wb_we_o <= '0';
				when wb_read =>
					s_axis_rx_ready_o <= '0';
					m_axis_tx_tvalid_o <= '0';
					m_axis_tx_tlast_o <= '0';
					m_axis_tx_tdata_o <= (others => '0');
					m_axis_tx_req_o <= '0';
					wb_cyc_o <= '0';
					wb_stb_o <= '0';
					wb_we_o <= '0';
				when h1h0_tx => 
					s_axis_rx_ready_o <= '0';
					m_axis_tx_tvalid_o <= '1';
					m_axis_tx_tlast_o <= '0';
					m_axis_tx_tdata_o <= X"000000044A000001"; -- 3DW header with data, CpID, Length = 1 
					m_axis_tx_req_o <= '1';
					wb_cyc_o <= '0';
					wb_stb_o <= '0';
					wb_we_o <= '0';
				when d0h2_tx =>
					s_axis_rx_ready_o <= '0';
					m_axis_tx_tvalid_o <= '1';
					m_axis_tx_tlast_o <= '1';
					m_axis_tx_tdata_o <= data_s & address_s & "00";
					m_axis_tx_req_o <= '1';
					wb_cyc_o <= '0';
					wb_stb_o <= '0';
					wb_we_o <= '0';
				when wait_1 | wait_2 =>
				    s_axis_rx_ready_o <= '1';
                    m_axis_tx_tvalid_o <= '0';
                    m_axis_tx_tlast_o <= '0';
                    --m_axis_tx_tdata_o <= (others => '0');
                    m_axis_tx_req_o <= '1';
                    wb_cyc_o <= '0';
                    wb_stb_o <= '0';
                    wb_we_o <= '0';
			end case;
	end process output_p;
	
	m_axis_tx_tkeep_o <= X"FF";
	m_axis_tx_tuser_o <= "0000";
	

end;
