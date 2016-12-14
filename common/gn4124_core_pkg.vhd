--==============================================================================
--! @file gn4124_core_pkg_s6.vhd
--==============================================================================

--! Standard library
library IEEE;
--! Standard packages
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Package for gn4124 core
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--! @brief
--! Package for components declaration and core wide constants.
--! Spartan6 FPGAs version.
--------------------------------------------------------------------------------
--! @version
--! 0.1 | mc | 01.09.2010 | File creation and Doxygen comments
--!
--! @author
--! mc : Matthieu Cattin, CERN (BE-CO-HT)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- GNU LESSER GENERAL PUBLIC LICENSE
--------------------------------------------------------------------------------
-- This source file is free software; you can redistribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published by the
-- Free Software Foundation; either version 2.1 of the License, or (at your
-- option) any later version. This source is distributed in the hope that it
-- will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
-- of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU Lesser General Public License for more details. You should have
-- received a copy of the GNU Lesser General Public License along with this
-- source; if not, download it from http://www.gnu.org/licenses/lgpl-2.1.html
--------------------------------------------------------------------------------


--==============================================================================
--! Package declaration
--==============================================================================
package gn4124_core_pkg is


--==============================================================================
--! Constants declaration
--==============================================================================
  constant c_RST_ACTIVE : std_logic := '0';  -- Active low reset


--==============================================================================
--! Functions declaration
--==============================================================================
  function f_byte_swap (
    constant enable    : boolean;
    signal   din       : std_logic_vector(63 downto 0);
    signal   byte_swap : std_logic_vector(2 downto 0))
    return std_logic_vector;

  function log2_ceil(N : natural) return positive;

--==============================================================================
--! Components declaration
--==============================================================================

-----------------------------------------------------------------------------



end gn4124_core_pkg;

package body gn4124_core_pkg is

  -----------------------------------------------------------------------------
  -- Byte swap function
  --
  -- enable | byte_swap  | din      | dout
  -- false  | XXX        | ABCDEFGH | ABCDEFGH
  -- true   | 000        | ABCDEFGH | ABCDEFGH
  -- true   | 001        | ABCDEFGH | BADCFEHG
  -- true   | 010        | ABCDEFGH | CDABGHEF
  -- true   | 011        | ABCDEFGH | DCBAHGFE
  -- true   | 100        | ABCDEFGH | EFGHABCD
  -- true   | 101        | ABCDEFGH | FEHGBADC
  -- true   | 110        | ABCDEFGH | GHEFCDAB
  -- true   | 111        | ABCDEFGH | HGFEDCBA
  -----------------------------------------------------------------------------
  function f_byte_swap (
    constant enable    : boolean;
    signal   din       : std_logic_vector(63 downto 0);
    signal   byte_swap : std_logic_vector(2 downto 0))
    return std_logic_vector is
    variable dout : std_logic_vector(63 downto 0) := din;
  begin
    if (enable = true) then
      case byte_swap is
        when "000" =>
          dout := din;
        when "001" =>
          dout := din(55 downto 48)   --B
		          & din(63 downto 56) --A
				  & din(39 downto 32) --D
				  & din(47 downto 40) --C
		          & din(23 downto 16) --F
                  & din(31 downto 24) --E
                  & din(7  downto  0) --H
                  & din(15 downto  8);--G
        when "010" =>
          dout := din(47 downto 32) --CD
				  & din(63 downto 48) --AB
		          & din(15 downto 0) --GH
                  & din(31 downto 16); --EF
				  
        when "011" =>
          dout := din(39 downto 32) --D
				  & din(47 downto 40) --C
		          & din(55 downto 48) --B
		          & din(63 downto 56) --A
		          & din(7 downto 0) --H
                  & din(15 downto 8) --G
                  & din(23 downto 16) --F
                  & din(31 downto 24); --E
		when "100" =>
          dout := din(31 downto 0)
		          & din(63 downto 32);
        when "101" =>
          dout := din(23 downto 16) --F
                  & din(31 downto 24) --E
                  & din(7  downto  0) --H
                  & din(15 downto  8) --G
				  & din(55 downto 48) --B
		          & din(63 downto 56) --A
				  & din(39 downto 32) --D
				  & din(47 downto 40);--C
        when "110" =>
          dout := din(15 downto 0) --GH
                  & din(31 downto 16) --EF
				  & din(47 downto 32) --CD
				  & din(63 downto 48); --AB
				  
        when "111" =>
          dout := din(7 downto 0) --H
                  & din(15 downto 8) --G
                  & din(23 downto 16) --F
                  & din(31 downto 24) --E
				  & din(39 downto 32) --D
				  & din(47 downto 40) --C
		          & din(55 downto 48) --B
		          & din(63 downto 56); --A
        when others =>
          dout := din;
      end case;
    else
      dout := din;
    end if;
    return dout;
  end function f_byte_swap;

  -----------------------------------------------------------------------------
  -- Returns log of 2 of a natural number
  -----------------------------------------------------------------------------
  function log2_ceil(N : natural) return positive is
  begin
    if N <= 2 then
      return 1;
    elsif N mod 2 = 0 then
      return 1 + log2_ceil(N/2);
    else
      return 1 + log2_ceil((N+1)/2);
    end if;
  end;

end gn4124_core_pkg;
