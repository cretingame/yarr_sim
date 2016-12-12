library IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

entity wb_master64 is
	Generic (
		axis_data_width_c : integer := 64;
		wb_address_width_c : integer := 64;
		wb_data_width_c : integer := 64;
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
end wb_master64;

architecture Behavioral of wb_master64 is
	constant fmt_h3dw_nodata_c : STD_LOGIC_VECTOR (3 - 1 downto 0):= "000";
	constant fmt_h3dw_data_c : STD_LOGIC_VECTOR (3 - 1 downto 0):= "001";
	constant fmt_h4dw_nodata_c : STD_LOGIC_VECTOR (3 - 1 downto 0):= "010";
	constant fmt_h4dw_data_c : STD_LOGIC_VECTOR (3 - 1 downto 0):= "011";
	constant fmt_tlp_prefix_c : STD_LOGIC_VECTOR (3 - 1 downto 0):= "100";
	
	constant tlp_type_Mr_c : STD_LOGIC_VECTOR (5 - 1 downto 0):= "00000";
	constant tlp_type_Cpl_c : STD_LOGIC_VECTOR (5 - 1 downto 0):= "01010";
	
	type state_t is (idle, hd0_rx, hd1_rx, wb_write, ignore, wb_read, hd0_tx, hd1_tx, lastdata_rx, data_tx);
	signal state_s : state_t;
	--signal wb_adr_s : STD_LOGIC_VECTOR (wb_address_width_c - 1 downto 0);
	signal wb_dat_o_s : STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
	signal wb_we_s : STD_LOGIC;
	signal payload_length_s : STD_LOGIC_VECTOR(9 downto 0);
	signal bar_hit_s : STD_LOGIC_VECTOR(6 downto 0);
	type tlp_type_t is (MRd,MRdLk,MWr,IORd,IOWr,CfgRd0,CfgWr0,CfgRd1,CfgWr1,TCfgRd,TCfgWr,Msg,MsgD,Cpl,CplD,CplLk,CplDLk,LPrfx,unknown);
	signal tlp_type_s : tlp_type_t;
	type header_t is (H3DW,H4DW);
	signal header_type_s : header_t;
	type bool_t is (false,true);
	signal payload_s : bool_t;
	signal tlp_prefix : bool_t;
	signal address_s : STD_LOGIC_VECTOR(wb_address_width_c-1 downto 0); 
	signal data_s : STD_LOGIC_VECTOR(64-1 downto 0);
	signal s_axis_rx_tdata_s : STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
	signal s_axis_rx_tkeep_s : STD_LOGIC_VECTOR (axis_data_width_c/8 - 1 downto 0);
	signal s_axis_rx_tuser_s : STD_LOGIC_VECTOR (21 downto 0);
	signal m_axis_tx_tdata_s : STD_LOGIC_VECTOR (axis_data_width_c - 1 downto 0);
	signal wb_dat_i_s : STD_LOGIC_VECTOR (wb_data_width_c - 1 downto 0);
	signal s_axis_rx_tlast_s : STD_LOGIC;
begin


	state_p:process(rst_i,clk_i) 
	begin
		if rst_i = '1' then
			state_s <= idle;
		elsif clk_i = '1' and clk_i'event then
			case state_s is
				when idle =>
					if s_axis_rx_tvalid_i = '1' then
						state_s <= hd0_rx;
					else
						state_s <= idle;
					end if;
				when hd0_rx =>
					if s_axis_rx_tvalid_i = '1' then
						--if s_axis_rx_tlast_i = '1' then
							state_s <= hd1_rx; -- 
						--end if;
					end if;
				when hd1_rx =>
					if s_axis_rx_tlast_s = '1' then
						if header_type_s = H3DW then
							state_s <= wb_write;
						elsif header_type_s = H4DW and tlp_type_s = MRd then
							state_s <= wb_write;
						else
							state_s <= ignore;
						end if;
					elsif s_axis_rx_tvalid_i = '1' and s_axis_rx_tlast_i = '1' then
						state_s <= lastdata_rx;
					elsif s_axis_rx_tvalid_i = '1' and s_axis_rx_tlast_i = '1' then
						state_s <= ignore; -- TODO: MORE DATA
					else
						state_s <= ignore; -- Ignore others packets type
					end if;
					
					
				when wb_write =>
					state_s <= wb_read;
				when ignore =>
					if s_axis_rx_tvalid_i = '1' then
						state_s <= ignore;
					else
						state_s <= idle;
					end if;
				when wb_read =>
					if wb_ack_i = '1' then
						if wb_we_s = '1' then
							state_s <= idle;
						elsif wb_we_s = '0' then
							state_s <= wb_read;
						else
							state_s <= hd0_tx;
						end if;
					end if;
				when hd0_tx => 
					if m_axis_tx_ready_i = '1' then
						state_s <= hd1_tx;
					end if;
				when hd1_tx =>
                    if m_axis_tx_ready_i = '1' and header_type_s <= H3DW then
                        state_s <= idle;
                    elsif m_axis_tx_ready_i = '1' and header_type_s <= H4DW then
                        state_s <= data_tx;
                    end if;
				when lastdata_rx => 
					state_s <= wb_write;
				when data_tx =>
					state_s <= idle;
			end case;
		end if;		
	end process state_p;
	
	delay_p: process(clk_i)
	begin
		if clk_i = '1' and clk_i'event then
			s_axis_rx_tdata_s <= s_axis_rx_tdata_i;
			s_axis_rx_tkeep_s <= s_axis_rx_tkeep_i;
			s_axis_rx_tuser_s <= s_axis_rx_tuser_i;
			s_axis_rx_tlast_s <= s_axis_rx_tlast_i;
			wb_dat_i_s <= wb_dat_i;
		end if;
	end process delay_p;
	
	reg_p: process(rst_i,clk_i)
	begin
		if rst_i = '1' then
			wb_dat_o_s <= (others => '0');
			address_s <= (others => '0');
			tlp_type_s <= unknown;
			header_type_s <= H4DW;
			wb_we_s <= '0';
		elsif clk_i = '1' and clk_i'event then
			case state_s is
				when hd0_rx =>

					bar_hit_s <= s_axis_rx_tuser_s(8 downto 2);
					payload_length_s <= s_axis_rx_tdata_s(9 downto 0);
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
				when hd1_rx =>
					if header_type_s = H3DW then -- d0h2_rx
						wb_dat_o_s <= X"00000000" & s_axis_rx_tdata_s(63 downto 32);
						address_s <= X"00000000" & s_axis_rx_tdata_s(31 downto 2) & "00" and address_mask_c; -- see 2.2.4.1. in pcie spec
					else -- H4DW h3h2_rx
						address_s(63 downto 32) <= s_axis_rx_tdata_s(31 downto 0) and address_mask_c(63 downto 32);
						address_s(31 downto 0) <= s_axis_rx_tdata_s(63 downto 36) & "0000" and address_mask_c(31 downto 0); 
					end if;
					
				when wb_read =>
					data_s <= wb_dat_i_s;
				
				when lastdata_rx =>
					-- if big endian
					wb_dat_o_s <= s_axis_rx_tdata_s; -- TODO: endianness
				
				when others =>

			end case;
		end if;
	end process reg_p;
	
	wb_adr_o <= address_s;
	wb_dat_o <= wb_dat_o_s;
	
	wb_output_p:process (state_s)
	begin
		case state_s is
			when wb_write =>
				wb_cyc_o <= '1';
				wb_stb_o <= '1';
				wb_we_o <= wb_we_s;
			when wb_read =>
				wb_cyc_o <= '0';
				wb_stb_o <= '0';
				wb_we_o <= '0';
			when others =>
				wb_cyc_o <= '0';
				wb_stb_o <= '0';
				wb_we_o <= '0';					
		end case;
	end process wb_output_p;
	
	axis_output_p:process (state_s,header_type_s,tlp_type_s)
	begin
		case state_s is
				when idle =>
					s_axis_rx_ready_o <= '1';
					m_axis_tx_tvalid_o <= '0';
					m_axis_tx_tlast_o <= '0';
					m_axis_tx_tdata_o <= (others => '0');
					m_axis_tx_req_o <= '0';
				when hd0_rx =>
					s_axis_rx_ready_o <= '1';
					m_axis_tx_tvalid_o <= '0';
					m_axis_tx_tlast_o <= '0';
					m_axis_tx_tdata_o <= (others => '0');
					m_axis_tx_req_o <= '0';
				when hd1_rx =>
					if s_axis_rx_tlast_s = '1' then
						s_axis_rx_ready_o <= '0';
					else
						s_axis_rx_ready_o <= '1';
					end if;
					m_axis_tx_tvalid_o <= '0';
					m_axis_tx_tlast_o <= '0';
					m_axis_tx_tdata_o <= (others => '0');
					m_axis_tx_req_o <= '0';
				when wb_write =>
					s_axis_rx_ready_o <= '0';
					m_axis_tx_tvalid_o <= '0';
					m_axis_tx_tlast_o <= '0';
					m_axis_tx_tdata_o <= (others => '0');
					m_axis_tx_req_o <= '0';
				when ignore =>
					s_axis_rx_ready_o <= '1';
					m_axis_tx_tvalid_o <= '0';
					m_axis_tx_tlast_o <= '0';
					m_axis_tx_tdata_o <= (others => '0');
					m_axis_tx_req_o <= '0';
				when wb_read =>
					s_axis_rx_ready_o <= '0';
					m_axis_tx_tvalid_o <= '0';
					m_axis_tx_tlast_o <= '0';
					m_axis_tx_tdata_o <= (others => '0');
					m_axis_tx_req_o <= '0';
				when hd0_tx => 
					s_axis_rx_ready_o <= '0';
					m_axis_tx_tvalid_o <= '1';
					m_axis_tx_tlast_o <= '0';
					m_axis_tx_tdata_o(63 downto 32) <= X"00000004";
					
					if header_type_s = H3DW then
						m_axis_tx_tdata_o(31 downto 0) <= "010" & "01010" & X"00" &  -- H0 FMT & type & some unused bits
							"000000" & payload_length_s; --H0 unused bits & length H & length L
					else
						m_axis_tx_tdata_o(31 downto 0) <= "011" & "01010" & X"00" &  -- H0 FMT & type & some unused bits
							"000000" & payload_length_s; --H0 unused bits & length H & length L
					end if;
					--m_axis_tx_tdata_o <= X"0000" & --H1 Requester ID
					   --X"00" & X"04" & --H1 Tag and Last DW BE and 1st DW BE
					   --"010" & "01010" & X"00" &  -- H0 FMT & type & some unused bits -- X"4000" &
					   --"000000" & "00" & X"01";  --H0 unused bits & length H & length L
					m_axis_tx_req_o <= '1';
				when hd1_tx =>
					s_axis_rx_ready_o <= '0';
					m_axis_tx_tvalid_o <= '1';
					if header_type_s = H3DW then
						m_axis_tx_tlast_o <= '1';
						m_axis_tx_tdata_o <= data_s(32-1 downto 0) & address_s(32-1 downto 0);
					else
						m_axis_tx_tlast_o <= '0';
						m_axis_tx_tdata_o <= address_s(31 downto 0) & address_s(63 downto 32);
					end if;
					
					m_axis_tx_req_o <= '1';
				when lastdata_rx => 
					s_axis_rx_ready_o <= '0';
					m_axis_tx_tvalid_o <= '0';
					m_axis_tx_tlast_o <= '0';
					m_axis_tx_tdata_o <= (others => '0');
					m_axis_tx_req_o <= '0';
				when data_tx =>
					s_axis_rx_ready_o <= '0';
					m_axis_tx_tvalid_o <= '1';
					m_axis_tx_tlast_o <= '1';
					m_axis_tx_tdata_o <= data_s; -- TODO: endianness
					m_axis_tx_req_o <= '1';				
			end case;
	end process axis_output_p;
	
	m_axis_tx_tkeep_o <= X"FF";
	m_axis_tx_tuser_o <= "0000";
	

end;
