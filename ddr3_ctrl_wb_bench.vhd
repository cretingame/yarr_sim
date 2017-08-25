----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/05/2017 11:36:38 AM
-- Design Name: 
-- Module Name: ddr3_ctrl_wb_bench - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;

entity ddr3_ctrl_wb_bench is
--  Port ( );
end ddr3_ctrl_wb_bench;

architecture Behavioral of ddr3_ctrl_wb_bench is

  component ddr3_ctrl_wb
    generic(
      g_BYTE_ADDR_WIDTH : integer := 29;
      g_MASK_SIZE       : integer := 8;
      g_DATA_PORT_SIZE  : integer := 64
      );
    port(
        ----------------------------------------------------------------------------
        -- Reset input (active low)
        ----------------------------------------------------------------------------
        rst_n_i : in std_logic;
    
        ----------------------------------------------------------------------------
        -- Status
        ----------------------------------------------------------------------------
    
        ----------------------------------------------------------------------------
        -- DDR controller port
        ----------------------------------------------------------------------------
        
        ddr_addr_o                  : out    std_logic_vector(g_BYTE_ADDR_WIDTH-1 downto 0);
        ddr_cmd_o                   : out    std_logic_vector(2 downto 0);
        ddr_cmd_en_o                : out    std_logic;
        ddr_wdf_data_o              : out    std_logic_vector(511 downto 0);
        ddr_wdf_end_o               : out    std_logic;
        ddr_wdf_mask_o              : out    std_logic_vector(63 downto 0);
        ddr_wdf_wren_o              : out    std_logic;
        ddr_rd_data_i               : in   std_logic_vector(511 downto 0);
        ddr_rd_data_end_i           : in   std_logic;
        ddr_rd_data_valid_i         : in   std_logic;
        ddr_rdy_i                   : in   std_logic;
        ddr_wdf_rdy_i               : in   std_logic;
        ddr_sr_req_o                : out    std_logic;
        ddr_ref_req_o               : out    std_logic;
        ddr_zq_req_o                : out    std_logic;
        ddr_sr_active_i             : in   std_logic;
        ddr_ref_ack_i               : in   std_logic;
        ddr_zq_ack_i                : in   std_logic;
        ddr_ui_clk_i                  : in   std_logic;
        ddr_ui_clk_sync_rst_i           : in   std_logic;
        ddr_init_calib_complete_i       : in   std_logic;
    
        ----------------------------------------------------------------------------
        -- Wishbone bus port
        ----------------------------------------------------------------------------
        wb_clk_i   : in  std_logic;
        wb_sel_i   : in  std_logic_vector(g_MASK_SIZE - 1 downto 0);
        wb_cyc_i   : in  std_logic;
        wb_stb_i   : in  std_logic;
        wb_we_i    : in  std_logic;
        wb_addr_i  : in  std_logic_vector(31 downto 0);
        wb_data_i  : in  std_logic_vector(g_DATA_PORT_SIZE - 1 downto 0);
        wb_data_o  : out std_logic_vector(g_DATA_PORT_SIZE - 1 downto 0);
        wb_ack_o   : out std_logic;
        wb_stall_o : out std_logic;
        
        ----------------------------------------------------------------------------
        -- Wishbone bus port
        ----------------------------------------------------------------------------
        wb1_sel_i   : in  std_logic_vector(g_MASK_SIZE - 1 downto 0);
        wb1_cyc_i   : in  std_logic;
        wb1_stb_i   : in  std_logic;
        wb1_we_i    : in  std_logic;
        wb1_addr_i  : in  std_logic_vector(32 - 1 downto 0);
        wb1_data_i  : in  std_logic_vector(g_DATA_PORT_SIZE - 1 downto 0);
        wb1_data_o  : out std_logic_vector(g_DATA_PORT_SIZE - 1 downto 0);
        wb1_ack_o   : out std_logic;
        wb1_stall_o : out std_logic      
      );
  end component ddr3_ctrl_wb;

    component wb_traffic_gen is
        generic (
            ADDR_WIDTH : integer := 32;
            DATA_WIDTH : integer := 64;
            WRITE : std_logic := '1';
            COUNTER_START : integer := 0
        );
        port (
            -- SYS CON
            clk			: in std_logic;
            rst			: in std_logic;
            en          : in std_logic;
            
            -- Wishbone Master out
            wb_adr_o			: out std_logic_vector(ADDR_WIDTH-1 downto 0);
            wb_dat_o			: out std_logic_vector(DATA_WIDTH-1 downto 0);
            wb_we_o				: out std_logic;
            wb_stb_o			: out std_logic;
            wb_cyc_o			: out std_logic; 
            
            -- Wishbone Master in
            --wb_dat_i			: in std_logic_vector(DATA_WIDTH-1 downto 0);
            --wb_ack_i			: in std_logic;
            wb_stall_i			: in std_logic
        );
    end component wb_traffic_gen;
	 
  
COMPONENT fifo_27x16_bench
    PORT (
      rst : IN STD_LOGIC;
      wr_clk : IN STD_LOGIC;
      rd_clk : IN STD_LOGIC;
      din : IN STD_LOGIC_VECTOR(28 DOWNTO 0);
      wr_en : IN STD_LOGIC;
      rd_en : IN STD_LOGIC;
      dout : OUT STD_LOGIC_VECTOR(28 DOWNTO 0);
      full : OUT STD_LOGIC;
      almost_full : OUT STD_LOGIC;
      empty : OUT STD_LOGIC
    );
  END COMPONENT;
  
component virtual_mig is
      generic (
          constant ADDR_WIDTH : integer := 16;
          constant DATA_WIDTH : integer := 512 
      );
      port (
          -- SYS CON
          clk            : in std_logic;
          rst            : in std_logic;
          
          -- DATA in
          adr_i            : in std_logic_vector(ADDR_WIDTH-1 downto 0);
          dat_i            : in std_logic_vector(DATA_WIDTH-1 downto 0);
          mask_i          : in std_logic_vector(DATA_WIDTH/8-1 downto 0);
          cmd_i           : in std_logic_vector(2 downto 0);
          en_i            : in std_logic; 
          
          -- DATA out
          dat_o            : out std_logic_vector(DATA_WIDTH-1 downto 0);
          valid_o            : out std_logic        
      );
  end component;
  
  constant period : time := 4 ns; -- 250MHz
  constant period_ddr : time := 7.5 ns; -- 533 Mhz/4
  constant g_BYTE_ADDR_WIDTH : integer := 29;
  constant g_MASK_SIZE       : integer := 8;
  constant g_DATA_PORT_SIZE  : integer := 64;
  
  --constant c_outoforder : std_logic := '0';
  constant c_write : std_logic := '0';
  constant c_read : std_logic := '1';
  
  --constant c_rd_valid : std_logic_vector := "00000000000000000000000000000000000000000000111100111100000000011010001000000000110100000000011010001000000000110100010000000001101000000000110100010000000001101000100000000010000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000110100010000000001101000000000110100010000000001101000100000000011010000000001101000100000000011010001000000000110100010000000001101000000000110100010000000001101000100000000011010001000000000110100000000011010001000000000110100010000000001101000000000110100000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010100010001000100000000010011001000000000110100000000011010001000000000110100010000000001101000100000000011010001000000000100000000100000000000000000000000000000011111011111110100000000011010001000000000110100000000011010001000000000110100010000000001101000100000000011000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
  
  signal clk_tbs : STD_LOGIC;
  signal rst_tbs : STD_LOGIC;
  signal rst_n_tbs : std_logic;
  
  --signal step : integer := 0;
  signal step_wb : integer := 0;
  signal step_ddr : integer := -16;
  
  
  signal ddr3_dq_s       : std_logic_vector(63 downto 0);
  signal ddr3_dqs_p_s    : std_logic_vector(7 downto 0);
  signal ddr3_dqs_n_s    : std_logic_vector(7 downto 0);

  signal ddr3_addr_s     : std_logic_vector(12 downto 0);
  signal ddr3_ba_s       : std_logic_vector(2 downto 0);
  signal ddr3_ras_n_s    : std_logic;
  signal ddr3_cas_n_s    : std_logic;
  signal ddr3_we_n_s     : std_logic;
  signal ddr3_reset_n_s  : std_logic;
  signal ddr3_ck_p_s     : std_logic_vector(0 downto 0);
  signal ddr3_ck_n_s     : std_logic_vector(0 downto 0);
  signal ddr3_cke_s      : std_logic_vector(0 downto 0);
  signal ddr3_cs_n_s     : std_logic_vector(0 downto 0);
  signal ddr3_dm_s       : std_logic_vector(7 downto 0);
  signal ddr3_odt_s      : std_logic_vector(0 downto 0);
  
  signal ddr_app_addr_s                  :     std_logic_vector(g_BYTE_ADDR_WIDTH-1 downto 0);
  signal ddr_app_addr_tbs                :     std_logic_vector(g_BYTE_ADDR_WIDTH-1 downto 0);
  signal ddr_app_addr_v_tbs              :     std_logic_vector(31 downto 0);
  signal ddr_app_addr_u_tbs              :     unsigned(31 downto 0);
  signal ddr_app_cmd_s                   :     std_logic_vector(2 downto 0);
  signal ddr_app_cmd_en_s                :     std_logic;
  signal ddr_app_wdf_data_s              :     std_logic_vector(511 downto 0);
  signal ddr_app_wdf_end_s               :     std_logic;
  signal ddr_app_wdf_mask_s              :     std_logic_vector(63 downto 0);
  signal ddr_app_wdf_wren_s              :     std_logic;
  signal ddr_app_rd_data_s               :     std_logic_vector(511 downto 0);
  signal ddr_app_rd_data_end_s           :     std_logic;
  signal ddr_app_rd_data_valid_s         :     std_logic;
  signal ddr_app_rdy_s                   :     std_logic;
  signal ddr_app_wdf_rdy_s               :     std_logic;
  signal ddr_app_ui_clk_s                :     std_logic;
  signal ddr_app_ui_clk_sync_rst_s       :     std_logic;
  
  signal ddr_counter : unsigned (31 downto 0);
  signal fifo_wr_s : std_logic;
  signal fifo_empty_s : std_logic;
  
  signal wb_addr_tbs : STD_LOGIC_VECTOR (32 - 1 downto 0);
  signal wb_dat_m2s_tbs : STD_LOGIC_VECTOR (64 - 1 downto 0);
  signal wb_dat_s2m_s : STD_LOGIC_VECTOR (64 - 1 downto 0);
  signal wb_cyc_tbs : STD_LOGIC;
  signal wb_sel_tbs : STD_LOGIC_VECTOR (8 - 1 downto 0);
  signal wb_stb_tbs : STD_LOGIC;
  signal wb_we_tbs : STD_LOGIC;
  signal wb_ack_s : STD_LOGIC;
  signal wb_stall_s : STD_LOGIC;
  
  signal wb_dat_s2m_tbs : STD_LOGIC_VECTOR (64 - 1 downto 0);
  signal wb_s2m_msg_tbs : STRING(1 to 2);

  signal wb1_addr_tbs : STD_LOGIC_VECTOR (32 - 1 downto 0);
  signal wb1_dat_m2s_tbs : STD_LOGIC_VECTOR (64 - 1 downto 0);
  signal wb1_dat_s2m_s : STD_LOGIC_VECTOR (64 - 1 downto 0);
  signal wb1_cyc_tbs : STD_LOGIC;
  signal wb1_sel_tbs : STD_LOGIC_VECTOR (8 - 1 downto 0);
  signal wb1_stb_tbs : STD_LOGIC;
  signal wb1_we_tbs : STD_LOGIC;
  signal wb1_ack_s : STD_LOGIC;
  signal wb1_stall_s : STD_LOGIC;
  
  signal wb1_dat_s2m_tbs : STD_LOGIC_VECTOR (64 - 1 downto 0);
  signal wb1_s2m_msg_tbs : STRING(1 to 2);

  signal read_en_tbs : std_logic;
  signal write_en_tbs : std_logic;

begin
    



    
	clk_p: process
	begin
		clk_tbs <= '1';
		wait for period/2;
		clk_tbs <= '0';
		wait for period/2;
	end process clk_p;
    
    ui_clk_p: process
    begin
        ddr_app_ui_clk_s <= '1';
        wait for period_ddr/2;
        ddr_app_ui_clk_s <= '0';
        wait for period_ddr/2;
    end process ui_clk_p;
    	
	
	
	reset_p: process
	begin
	   rst_tbs <= '1';
	   wait for period;
	   rst_tbs <= '0';
	   wait;
	end process reset_p;
    
    rst_n_tbs <= not rst_tbs;
    
    
	enable_p: process
    begin
       write_en_tbs <= '0';
       read_en_tbs <= '0';
       wait for 5*period;
       write_en_tbs <= '1';
       wait for 4*period;
       read_en_tbs <= '1';
        
       wait;
    end process enable_p;
    
    rst_n_tbs <= not rst_tbs;    


    wb_read_comp: wb_traffic_gen
        generic map (
            ADDR_WIDTH => 32,
            DATA_WIDTH => 64,
            WRITE => '0',
            COUNTER_START =>  0
        )
        port map (
            -- SYS CON
            clk            => clk_tbs,
            rst            => rst_tbs,
            en             => read_en_tbs,
            
            -- Wishbone Master out
            wb_adr_o            => wb_addr_tbs,
            wb_dat_o            => wb_dat_m2s_tbs,
            wb_we_o             => wb_we_tbs,
            wb_stb_o            => wb_stb_tbs,
            wb_cyc_o            => wb_cyc_tbs,
            
            -- Wishbone Master in
            --wb_dat_i            : in std_logic_vector(DATA_WIDTH-1 downto 0);
            --wb_ack_i            : in std_logic;
            wb_stall_i            => wb_stall_s
        );
    
    wb_sel_tbs <= (others => '1');
 
    wb1_write_comp: wb_traffic_gen
        generic map (
            ADDR_WIDTH => 32,
            DATA_WIDTH => 64,
            WRITE => '1',
            COUNTER_START =>  0
        )
        port map (
            -- SYS CON
            clk            => clk_tbs,
            rst            => rst_tbs,
            en             => write_en_tbs,
            
            -- Wishbone Master out
            wb_adr_o            => wb1_addr_tbs,
            wb_dat_o            => wb1_dat_m2s_tbs,
            wb_we_o             => wb1_we_tbs,
            wb_stb_o            => wb1_stb_tbs,
            wb_cyc_o            => wb1_cyc_tbs,
            
            -- Wishbone Master in
            --wb_dat_i            : in std_logic_vector(DATA_WIDTH-1 downto 0);
            --wb_ack_i            : in std_logic;
            wb_stall_i            => wb1_stall_s
        );
    
    wb1_sel_tbs <= (others => '1');
 
    
    s2m_wb_check_p : process
        variable counter_v : unsigned (31 downto 0);
    begin
    
    wb_dat_s2m_tbs <= (others => '0');
    counter_v := (others => '1'); --to_unsigned(0,32);
    wb_s2m_msg_tbs <= "NO";
    --wait for period;
    wait until wb_ack_s = '1';
        
    loop
        if(wb_ack_s = '1') then
            counter_v := counter_v + 1;
            if (wb_dat_s2m_tbs = wb_dat_s2m_s) then
                wb_s2m_msg_tbs <= "OK";
            else
                wb_s2m_msg_tbs <= "KO";
            end if;
        end if;
        
        --wb_dat_s2m_tbs <= X"deadbeef" & std_logic_vector(counter_v);
        wb_dat_s2m_tbs <= X"00000000" & std_logic_vector(counter_v);
    
    
    
    wait for period;
    
    end loop;
    
    wait;
    
    end process s2m_wb_check_p;
    
    wb_step_p : process
    begin
    
    wait for period;
    
    step_wb <= step_wb + 1;
    
    end process wb_step_p;
    
    ddr_step_p : process
    begin
    
    wait for period_ddr;
    
    step_ddr <= step_ddr + 1;
    
    end process ddr_step_p;
    
    with step_ddr select ddr_app_rdy_s <=
        '0' when 16 to 25 | 258 to 259 | 752 to 753 | 882 to 883 | 887 to 888 | 996 to 998 | 1003 to 1023,
        '1' when others;
    
    with step_ddr select ddr_app_wdf_rdy_s <= 
        --'0' when 150,
        '1' when others;

    
--    ddr_app_rd_data_valid_s <= not fifo_empty_s;
--    fifo_wr_s <= ddr_app_cmd_en_s and ddr_app_rdy_s;
                             
--    ddr_app_rd_data_end_s <= '1';
    
    
--    ddr_app_addr_v_tbs <= "000" & ddr_app_addr_tbs;
--    ddr_app_addr_u_tbs <= unsigned(ddr_app_addr_v_tbs);
    
--    ddr_app_rd_data_s       <= X"deadbeef" & std_logic_vector(ddr_app_addr_u_tbs+7) &
--                               X"deadbeef" & std_logic_vector(ddr_app_addr_u_tbs+6) &
--                               X"deadbeef" & std_logic_vector(ddr_app_addr_u_tbs+5) &
--                               X"deadbeef" & std_logic_vector(ddr_app_addr_u_tbs+4) &
--                               X"deadbeef" & std_logic_vector(ddr_app_addr_u_tbs+3) & 
--                               X"deadbeef" & std_logic_vector(ddr_app_addr_u_tbs+2) & 
--                               X"deadbeef" & std_logic_vector(ddr_app_addr_u_tbs+1) & 
--                               X"deadbeef" & std_logic_vector(ddr_app_addr_u_tbs+0) when ddr_app_rd_data_valid_s = '1' else
--                               (others => '0');
                               
--    fifo_wb_read_addr : fifo_27x16_bench
--     PORT MAP (
--       rst => rst_tbs,
--       wr_clk => ddr_app_ui_clk_s,
--       rd_clk => ddr_app_ui_clk_s,
--       din => ddr_app_addr_s,
--       wr_en => fifo_wr_s,
--       rd_en => ddr_app_rd_data_valid_s,
--       dout => ddr_app_addr_tbs,
--       full => open,
--       almost_full => open,
--       empty => fifo_empty_s
--     );
    
    ddr_stimuli_p : process
        
        variable data_end : std_logic;
    begin
    
    
    ddr_counter <= to_unsigned(0,32);
    
    loop
    

    wait for period_ddr;
    if ddr_app_rd_data_valid_s = '1' then

        ddr_counter <= ddr_counter + 8;


        
        data_end := not data_end;
        
    else
        

        
    end if;
    end loop;
    
    wait;
    
    
    end process ddr_stimuli_p;

  cmp_ddr3_ctrl_wb : ddr3_ctrl_wb
    generic map(
      g_BYTE_ADDR_WIDTH => g_BYTE_ADDR_WIDTH,
      g_MASK_SIZE       => g_MASK_SIZE,
      g_DATA_PORT_SIZE  => g_DATA_PORT_SIZE
      )
    port map(
      rst_n_i             => rst_n_tbs,
      
      ddr_addr_o          => ddr_app_addr_s,
      ddr_cmd_o           => ddr_app_cmd_s,
      ddr_cmd_en_o        => ddr_app_cmd_en_s,
      ddr_wdf_data_o      => ddr_app_wdf_data_s,
      ddr_wdf_end_o       => ddr_app_wdf_end_s,
      ddr_wdf_mask_o      => ddr_app_wdf_mask_s,
      ddr_wdf_wren_o      => ddr_app_wdf_wren_s,
      ddr_rd_data_i       => ddr_app_rd_data_s,
      ddr_rd_data_end_i   => ddr_app_rd_data_end_s,
      ddr_rd_data_valid_i => ddr_app_rd_data_valid_s,
      ddr_rdy_i           => ddr_app_rdy_s,
      ddr_wdf_rdy_i       => ddr_app_wdf_rdy_s,
      ddr_ui_clk_i        => ddr_app_ui_clk_s,
      ddr_ui_clk_sync_rst_i => ddr_app_ui_clk_sync_rst_s,
      ddr_sr_req_o        => open,
      ddr_ref_req_o       => open,
      ddr_zq_req_o        => open,
      ddr_sr_active_i     => '1',
      ddr_ref_ack_i       => '1',
      ddr_zq_ack_i        => '1',
      ddr_init_calib_complete_i => '1',
      
      wb_clk_i            => clk_tbs,
      wb_sel_i            => wb_sel_tbs,
      wb_cyc_i            => wb_cyc_tbs,
      wb_stb_i            => wb_stb_tbs,
      wb_we_i             => wb_we_tbs,
      wb_addr_i           => wb_addr_tbs,
      wb_data_i           => wb_dat_m2s_tbs,
      wb_data_o           => wb_dat_s2m_s,
      wb_ack_o            => wb_ack_s,
      wb_stall_o          => wb_stall_s,
      
      ----------------------------------------------------------------------------
      -- Wishbone bus port
      ----------------------------------------------------------------------------
      wb1_sel_i   => wb1_sel_tbs,
      wb1_cyc_i   => wb1_cyc_tbs,     
      wb1_stb_i   => wb1_stb_tbs,     
      wb1_we_i    => wb1_we_tbs,      
      wb1_addr_i  => wb1_addr_tbs,    
      wb1_data_i  => wb1_dat_m2s_tbs, 
      wb1_data_o  => wb1_dat_s2m_s,   
      wb1_ack_o   => wb1_ack_s,       
      wb1_stall_o => wb1_stall_s     
      
      );

    comp_virtual_mig:virtual_mig
      generic map (
          ADDR_WIDTH => 12,
          DATA_WIDTH => 512 
      )
      port map (
          -- SYS CON
          clk            => ddr_app_ui_clk_s,
          rst            => rst_tbs,
         
          -- DATA i
          adr_i          => ddr_app_addr_s(12-1 downto 0),
          dat_i          => ddr_app_wdf_data_s,
          mask_i         => ddr_app_wdf_mask_s,
          cmd_i          => ddr_app_cmd_s,
          en_i           => ddr_app_cmd_en_s,
         
          -- DATA ou
          dat_o           => ddr_app_rd_data_s,
          valid_o         => ddr_app_rd_data_valid_s
      );
      
      ddr_app_rd_data_end_s <= ddr_app_rd_data_valid_s;
      
--    u_mig_7series_0 : mig_7series_0
--    port map (
--        -- Memory interface ports
--        ddr3_addr                      => ddr3_addr_s,
--        ddr3_ba                        => ddr3_ba_s,
--        ddr3_cas_n                     => ddr3_cas_n_s,
--        ddr3_ck_n                      => ddr3_ck_n_s,
--        ddr3_ck_p                      => ddr3_ck_p_s,
--        ddr3_cke                       => ddr3_cke_s,
--        ddr3_ras_n                     => ddr3_ras_n_s,
--        ddr3_reset_n                   => ddr3_reset_n_s,
--        ddr3_we_n                      => ddr3_we_n_s,
--        ddr3_dq                        => ddr3_dq_s,
--        ddr3_dqs_n                     => ddr3_dqs_n_s,
--        ddr3_dqs_p                     => ddr3_dqs_p_s,
--        init_calib_complete            => open,
--        ddr3_cs_n                      => ddr3_cs_n_s,
--        ddr3_dm                        => ddr3_dm_s,
--        ddr3_odt                       => ddr3_odt_s,
--        -- Application interface ports
--        app_addr                       => ddr_app_addr_s,
--        app_cmd                        => ddr_app_cmd_s,
--        app_en                         => ddr_app_cmd_en_s,
--        app_wdf_data                   => ddr_app_wdf_data_s,
--        app_wdf_end                    => ddr_app_wdf_end_s,
--        app_wdf_wren                   => ddr_app_wdf_wren_s,
--        app_rd_data                    => ddr_app_rd_data_s,
--        app_rd_data_end                => ddr_app_rd_data_end_s,
--        app_rd_data_valid              => ddr_app_rd_data_valid_s,
--        app_rdy                        => ddr_app_rdy_s,
--        app_wdf_rdy                    => ddr_app_wdf_rdy_s,
--        app_sr_req                     => '0',
--        app_ref_req                    => '0',
--        app_zq_req                     => '0',
--        app_sr_active                  => open,
--        app_ref_ack                    => open,
--        app_zq_ack                     => open,
--        ui_clk                         => ddr_app_ui_clk_s,
--        ui_clk_sync_rst                => ddr_app_ui_clk_sync_rst_s,
--        app_wdf_mask                   => ddr_app_wdf_mask_s,
--        -- System Clock Ports
--        sys_clk_i                       => clk_tbs,
--        -- Reference Clock Ports
--        clk_ref_i                      => clk_tbs,
--        sys_rst                        => rst_n_tbs
--    );

end Behavioral;
