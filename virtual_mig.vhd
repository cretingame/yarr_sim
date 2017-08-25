----------------------------------------------------------------------------------
-- Company: 			University of Wuppertal
-- Engineer: 			Timon Heim
-- E-Mail:				heim@physik.uni-wuppertal.de
--
-- Project:				IBL BOC firmware
-- Module:				Block RAM
-- Description:		Block RAM with Wishbone Slave Interface
----------------------------------------------------------------------------------
-- Changelog:
-- 20.02.2011 - Initial Version
----------------------------------------------------------------------------------
-- TODO:
-- 20.02.2011 - Add DMA capability
----------------------------------------------------------------------------------
-- Address Map:
-- 0x020 to 0x02F
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

--library work;
--use work.bocpack.all;

entity virtual_mig is
	generic (
		constant ADDR_WIDTH : integer := 11;
		constant DATA_WIDTH : integer := 512 
	);
	port (
		-- SYS CON
		clk			: in std_logic;
		rst			: in std_logic;
		
		-- DATA in
		adr_i			: in std_logic_vector(ADDR_WIDTH-1 downto 0);
		dat_i			: in std_logic_vector(DATA_WIDTH-1 downto 0);
		mask_i          : in std_logic_vector(DATA_WIDTH/8-1 downto 0); --nyi
		cmd_i           : in std_logic_vector(2 downto 0);
		en_i			: in std_logic; 
		
		-- DATA out
		dat_o			: out std_logic_vector(DATA_WIDTH-1 downto 0);
		valid_o			: out std_logic		
	);
end virtual_mig;
	 
architecture Behavioral of virtual_mig is

   constant c_byte_num : integer  := 3;
   type ram_type is array (2**ADDR_WIDTH-c_byte_num-1 downto 0) of std_logic_vector (DATA_WIDTH-1 downto 0);
   signal RAM: ram_type;
	
   signal ADDR : std_logic_vector(ADDR_WIDTH-c_byte_num-1 downto 0);
	 
begin
	
	ADDR <= adr_i(ADDR_WIDTH-1 downto c_byte_num);
	
	bram: process (clk, rst)
	begin
		if (rst ='1') then
			valid_o <= '0';
			for i in 0 to 2**(ADDR_WIDTH-c_byte_num-1) loop
--				RAM(i) <= conv_std_logic_vector(i,RAM(i)'length); -- "DEAD0001BEEF0001"
--                RAM(i)(DATA_WIDTH-1 downto DATA_WIDTH/2) <= conv_std_logic_vector(i,RAM(i)'length/2);
--                RAM(i)(DATA_WIDTH-1 downto DATA_WIDTH-4*4) <= x"DEAD";
--                RAM(i)(DATA_WIDTH-1-DATA_WIDTH/2 downto DATA_WIDTH-4*4-DATA_WIDTH/2) <= x"BEEF";
                RAM(i) <=
                 X"deadbeef" & conv_std_logic_vector(i*8+7,32) &
                 X"deadbeef" & conv_std_logic_vector(i*8+6,32) &
                 X"deadbeef" & conv_std_logic_vector(i*8+5,32) &
                 X"deadbeef" & conv_std_logic_vector(i*8+4,32) &
                 X"deadbeef" & conv_std_logic_vector(i*8+3,32) & 
                 X"deadbeef" & conv_std_logic_vector(i*8+2,32) & 
                 X"deadbeef" & conv_std_logic_vector(i*8+1,32) & 
                 X"deadbeef" & conv_std_logic_vector(i*8+0,32); 
                
			end loop;
		elsif (clk'event and clk = '1') then
			if (en_i = '1') then
				
				if (cmd_i = "000") then
					RAM(conv_integer(ADDR)) <= dat_i;
					valid_o <= '0';
			    elsif (cmd_i = "001") then
			         valid_o <= '1';
			    else
			         valid_o <= '0';
				end if;
				dat_o <= RAM(conv_integer(ADDR)) ;
			else
				valid_o <= '0';
			end if;
		end if;
	end process bram;

end Behavioral;
