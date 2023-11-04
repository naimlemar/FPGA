-------------------------------------------------------------------------------
-- Copyright 2023 Naim Lemar
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>
-------------------------------------------------------------------------------

--***********************************************
--* Platform: Terasic DE2-115
--* Date: 21/08/2023
--* Description:
--*     The module implements a simple 64-bit clock counter
--*     connected to the Avalon-MM interface as a slave 
--*     (see its full description in Appendix A of the report)
--***********************************************
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ClockCounter is
    Port (
        clock        : in STD_LOGIC;
        reset        : in STD_LOGIC;
        csr_read     : in STD_LOGIC;
        csr_write    : in STD_LOGIC;
        csr_address  : in STD_LOGIC;
        csr_readdata : out STD_LOGIC_VECTOR(31 downto 0);
        csr_writedata: in STD_LOGIC_VECTOR(31 downto 0)
    );
end ClockCounter;

architecture Behavioral of ClockCounter is
    signal counter   : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
    signal hSnapshot : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin
    process(clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                counter <= (others => '0');
            else
                if csr_write = '1' then
                    counter <= (others => '0');
                else
                    counter <= counter + 1;
                end if;
                
                if csr_read = '1' then
                    case csr_address is
                        when '0' =>
                            hSnapshot <= counter(63 downto 32);
                            csr_readdata <= counter(31 downto 0);
                        when '1' =>
                            csr_readdata <= hSnapshot;
                        when others =>
                            null;
                    end case;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
