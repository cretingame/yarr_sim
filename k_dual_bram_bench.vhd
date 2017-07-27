----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07/19/2017 04:02:52 PM
-- Design Name: 
-- Module Name: k_dual_bram_bench - Behavioral
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

entity k_dual_bram_bench is
--  Port ( );
end k_dual_bram_bench;

architecture Behavioral of k_dual_bram_bench is
    signal clk_tbs : std_logic;
    signal rst_tbs : std_logic;
    constant period : time := 100 ns;
	---------------------------------------------------------
    -- From DMA master to Dummy RAM
    signal dma_bram_adr_tbs   :  std_logic_vector(32-1 downto 0);       -- Adress
    signal dma_bram_dat_s2m_s   :  std_logic_vector(64-1 downto 0);   -- Data in
    signal dma_bram_dat_m2s_tbs   :  std_logic_vector(64-1 downto 0);   -- Data out
    signal dma_bram_sel_tbs   :  std_logic_vector(8-1 downto 0);        -- Byte select
    signal dma_bram_cyc_tbs   :  std_logic;                             -- Read or write cycle
    signal dma_bram_stb_tbs   :  std_logic;                             -- Read or write strobe
    signal dma_bram_we_tbs    :  std_logic;                             -- Write
    signal dma_bram_ack_s   :  std_logic;                             -- Acknowledge
    signal dma_bram_stall_s :  std_logic;                             -- for pipelined Wishbone 

    component k_dual_bram is
        Port ( 
        -- SYS CON
        clk_i            : in std_logic;
        rst_i            : in std_logic;
        
        -- Wishbone Slave in
        wba_adr_i            : in std_logic_vector(32-1 downto 0);
        wba_dat_i            : in std_logic_vector(64-1 downto 0);
        wba_we_i            : in std_logic;
        wba_stb_i            : in std_logic;
        wba_cyc_i            : in std_logic; 
        
        -- Wishbone Slave out
        wba_dat_o            : out std_logic_vector(64-1 downto 0);
        wba_ack_o            : out std_logic;
               
        -- Wishbone Slave in
        wbb_adr_i            : in std_logic_vector(32-1 downto 0);
        wbb_dat_i            : in std_logic_vector(64-1 downto 0);
        wbb_we_i            : in std_logic;
        wbb_stb_i            : in std_logic;
        wbb_cyc_i            : in std_logic; 
        
        -- Wishbone Slave out
        wbb_dat_o            : out std_logic_vector(64-1 downto 0);
        wbb_ack_o            : out std_logic 
               
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
	
	stimuli_p : process
	begin
        dma_bram_adr_tbs   <= (others => '0');
        dma_bram_dat_m2s_tbs  <= (others => '0');
        dma_bram_sel_tbs   <= (others => '1');
        dma_bram_cyc_tbs   <= '0';
        dma_bram_stb_tbs   <= '0';
        dma_bram_we_tbs    <= '0';
        dma_bram_stall_s   <= '0'; 	   
	   wait for 2*period;
	   for I in 0 to 16#200# loop
           dma_bram_adr_tbs   <= std_logic_vector(to_unsigned(I,32));
           dma_bram_dat_m2s_tbs  <= X"DEADBEEF" & std_logic_vector(to_unsigned(I,32));
           dma_bram_sel_tbs   <= (others => '1');
           dma_bram_cyc_tbs   <= '1';
           dma_bram_stb_tbs   <= '1';
           dma_bram_we_tbs    <= '1';
           dma_bram_stall_s   <= '0';
           wait for period; 
       end loop;
       dma_bram_adr_tbs   <= X"0000200A";
       dma_bram_dat_m2s_tbs  <= X"DEADBEEF0000000B";
       dma_bram_sel_tbs   <= (others => '1');
       dma_bram_cyc_tbs   <= '1';
       dma_bram_stb_tbs   <= '1';
       dma_bram_we_tbs    <= '1';
       dma_bram_stall_s   <= '0';        
       wait for period;
       dma_bram_adr_tbs   <= (others => '0');
       dma_bram_dat_m2s_tbs  <= (others => '0');
       dma_bram_sel_tbs   <= (others => '1');
       dma_bram_cyc_tbs   <= '0';
       dma_bram_stb_tbs   <= '0';
       dma_bram_we_tbs    <= '0';
       dma_bram_stall_s   <= '0'; 
       wait for period;
	   for I in 0 to 16#200# loop
           dma_bram_adr_tbs   <= std_logic_vector(to_unsigned(I,32));
           dma_bram_dat_m2s_tbs  <= (others => '0');
           dma_bram_sel_tbs   <= (others => '1');
           dma_bram_cyc_tbs   <= '1';
           dma_bram_stb_tbs   <= '1';
           dma_bram_we_tbs    <= '0';
           dma_bram_stall_s   <= '0';
           wait for period; 
       end loop;
       dma_bram_adr_tbs   <= (others => '0');
       dma_bram_dat_m2s_tbs  <= (others => '0');
       dma_bram_sel_tbs   <= (others => '1');
       dma_bram_cyc_tbs   <= '0';
       dma_bram_stb_tbs   <= '0';
       dma_bram_we_tbs    <= '0';
       dma_bram_stall_s   <= '0';
       wait for period;

       wait; 
	end process;

     dual_dma_ram: k_dual_bram
     Port Map( 
         -- SYS CON
         clk_i            => clk_tbs,
         rst_i            => rst_tbs,
         
         -- Wishbone Slave in
         wba_adr_i            => dma_bram_adr_tbs,
         wba_dat_i            => dma_bram_dat_m2s_tbs,
         wba_we_i             => dma_bram_we_tbs,
         wba_stb_i            => dma_bram_stb_tbs,
         wba_cyc_i            => dma_bram_cyc_tbs, 
         
         -- Wishbone Slave out
         wba_dat_o            => dma_bram_dat_s2m_s,
         wba_ack_o            => dma_bram_ack_s,
                
         -- Wishbone Slave in
         wbb_adr_i            => (others => '0'),
         wbb_dat_i            => (others => '0'),
         wbb_we_i             => '0',
         wbb_stb_i            => '0',
         wbb_cyc_i            => '0', 
         
         -- Wishbone Slave out
         wbb_dat_o            => open,
         wbb_ack_o            => open
                
       );


end Behavioral;
